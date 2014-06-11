#encoding: utf-8

require 'resolv'
require 'socket'
require 'packetfu'

module RDOS

  module PLUGIN

    class Test < Base

      def init
        plugin_name = "test"
        plugin_desc = "测试"
        update_info(plugin_name, plugin_desc, {})
      end

      def test
        return true
      end

      def dos
        p "1111"
        sleep(5)
      end

    end

  end

end
