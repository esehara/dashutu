module Dashutu
  module M2
    class Env
      def initialize
        @env = {}
      end

      def add(k, v)
        @env[k] = v
      end

      def to_s
        (@env.map {|k, v| "#{k} = #{v}" }.join ",") + "|-"
      end
    end
  end
end
