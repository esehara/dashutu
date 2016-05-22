class Fixnum
  def value
    self
  end

  def var!
    @env = env
  end

  def to_ml2
    @env.to_s + "#{self} evalto #{self} by E-Int {};"
  end
end


module Dashutu
  module ML2
    class Environment
      def initialize
        @var = []
      end

      def var!(x, y)
        @var << [x, y]
        self
      end

      def to_s
        @var.map {|k, v| "#{k} = #{v}"}.join(" , ") + "|-"
      end
    end

    class EBase < Struct.new(:e1, :e2)
      def var!
        @env = env
      end

      def lastline
        "#{e1.value} #{lastop} #{e2.value} is #{apply} #{lastby} {};"
      end

      def to_ml2
        e3 = apply
        return (
          "#{e1.value} #{op} #{e2.value} evalto #{e3} {\n" +
          "  #{e1.to_ml2}\n" +
          "  #{e2.to_ml2}\n" +
          "  #{lastline}\n" +
          "}")
      end
    end

    class EPlus < EBase
      def ml2_name
        " by E-Plus "
      end

      def lastop
        "plus"
      end

      def lastby
        " by B-Plus "
      end

      def op
        "+"
      end

      def apply
        e1.value + e2.value
      end
    end

    class EMinus < EBase
      def ml2_name
        " by E-Minus "
      end

      def lastop
        "minus"
      end

      def lastby
        " by B-Minus "
      end

      def op
        "+"
      end

      def apply
        e1.value - e2.value
      end
    end
  end
end
