class Fixnum
  def value
    self
  end

  def name
    self
  end

  def to_ml2
    "#{self} evalto #{self} by E-Int {};"
  end
end

class TrueClass
  def value
    self
  end

  def name
    self
  end

  def to_ml2
    "#{self} evalto #{self} by E-Bool {};"
  end
end

class FalseClass
  def value
    self
  end

  def name
    self
  end

  def to_ml2
    "#{self} evalto #{self} by E-Bool {};"
  end
end

module Dashutu
  module ML2
    class Environment
      def initialize
        @var = []
      end

      def var
        @var
      end

      def var_clone
        @var = @var.clone
      end

      def var!(x, y)
        @var << [x, y]
        self
      end

      def eval(exp)
        exp.var! self
        exp.to_ml2
      end

      def to_ml2
        @var.map {|k, v| "#{k} = #{v}"}.join(" , ") + " |- "
      end
    end

    class LETIN < Struct.new(:name, :e1, :e2)
      def to_ml2
      end
    end
    
    class EBase < Struct.new(:e1, :e2)
      def var!(env)
        @env = env.clone
      end

      def lastline
        "#{e1.value} #{lastop} #{e2.value} is #{apply} #{lastby} {};"
      end

      def env_s
        if !@env.nil?
          @env.to_ml2
        else
          "|- "
        end
      end

      def prepare
        e1.var! @env if e1.is_a? Var
        e2.var! @env if e2.is_a? Var
      end

      def to_ml2
        prepare
        e3 = apply
        return (
          env_s + "#{e1.name} #{op} #{e2.name} evalto #{e3} {\n" +
          "  #{env_s}#{e1.to_ml2}\n" +
          "  #{env_s}#{e2.to_ml2}\n" +
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

    class Var
      def initialize k
        @key = k
      end

      def name
        @key
      end

      def value
        _, v = search
        return v
      end

      def var! env
        @env = env
      end

      def env_s
        if !@env.nil?
          @env.to_ml2
        else
          "|- "
        end
      end

      def var1?
        k, v = @env.var[-1]
        k == @key
      end

      def search
        @env.var.each do |k, v|
          return k, v if @key == k
        end
      end

      def to_ml2
        if var1?
          k, v = @env.var[-1]
          env_s + "#{k} evalto #{v} by E-Var1 {};"
        else
          v2 = Var.new @key
          env = @env.clone
          env.var_clone
          env.var.pop
          v2.var! env
          k, v = search

          env_s + "#{k} evalto #{v} by E-Var2 {\n" +
            "  " + v2.to_ml2 + "\n" +
          "}"
        end
      end
    end
  end
end
