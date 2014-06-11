#encoding: utf-8

require 'thread'

module RDOS
  module PLUGIN
    class Base

        def update_info(name, desc, args = nil)
            @info = {:name => name, :desc => desc}
            @args = args
            return self
        end

        def name
            @info[:name] ? @info[:name] : ""
        end

        def desc
            @info[:desc]
        end

        def args
            @args
        end

        def test
            return true
        end

        def dos
        end

        def run
            thread_num = RDOS::Options['Thread'].to_i ? RDOS::Options['Thread'].to_i : 1
            thread_list = []
            0.upto(thread_num) do
                thread_list << Thread.new { dos }
            end
            thread_list.each do |t|
                t.join
            end
        end
    end
  end
end

