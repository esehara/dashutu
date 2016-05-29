class Fixnum
  def ml2_value
    self
  end

  def step?
    false
  end

  def ml2_s
    "#{self} evalto #{self} by E-Int {};"
  end
end

module ML2
  class Env
    def initialize
      @env = []
    end

    def var1? k
      @env[-1][0] == k
    end

    def var2? k
      @env.each { |key, _| return true if key == k }
      return false
    end

    def var2_value k
      @env.each { |key, value| return value if key == k}
    end

    def var1 k
      Var1.new(k, @env[-1][1], self)
    end

    def pop!
      @env = @env.clone
      @env.pop
    end

    def var2 k
      Var2.new(k, var2_value(k), self)
    end

    def env! value
      @env = value
      return self
    end

    def ml2_s
      s = @env.map {|k, v| "#{k} = #{v}"}.join(", ")
      return (s.empty? ? "" : s) + " |- "
    end
  end

  class LETIN
    def initialize(name, e1, e2)
      @name = name
      @e1 = e1
      @e2 = e2
      @env = Env.new
      @step = 0
    end

    def ml2_s
      @env.ml2_s + "let #{@name} = #{@e1.ml2_s} in #{@e2.ml2_s}"
    end

    def env! value
      @env = Env.new.env! value
      return self
    end

    def step?
      true
    end

    def step
      next_env = @env.clone
      @e1 = @e1.env!(@env).step
      @e2 = @e2.env!(@env).step
    end
  end

  class ML2EBase
    def initialize(e1, e2, env)
      if env.nil?
        @env = Env.new
      else
        @env = env
      end
      @e1 = e1
      @e2 = e2
    end

    def prepare
      @e1 = varize @e1
      @e2 = varize @e2
    end

    def varize e1
      if e1.is_a? String
        return @env.var1 e1 if @env.var1? e1
        return @env.var2 e1 if @env.var2? e1
      end
      return e1
    end

    def prepare_ml2_s e1
      if e1.is_a? Integer
        "  #{@env.ml2_s}#{e1.ml2_s} \n"
      else
        "  #{e1.ml2_s} \n"
      end
    end
  end

  class Var2
    def initialize(e1, e2, env)
      @e1 = e1
      @e2 = e2
      @env = env
    end

    def prepare
      next_env = @env.clone
      next_env.pop!
      @e1 = next_env.var1 @e1
    end

    def ml2_s
      prepare
      "#{@env.ml2_s}#{@e1} evalto #{@e2} by E-Val2 {\n" +
        "  #{@e1.ml2_s} \n" +
        "\n};"
    end

    def ml2_value
      @e2
    end

    def to_s
      @e1.to_s
    end
  end

  class Var1
    def initialize(e1, e2, env)
      @e1 = e1
      @e2 = e2
      @env = env
    end

    def ml2_s
      "#{@env.ml2_s}#{@e1} evalto #{@e2} by E-Val1 {};"
    end

    def ml2_value
      @e2
    end

    def to_s
      @e1
    end
  end

  class ETIMES < ML2EBase
    def value
      @e1.ml2_value * @e2.ml2_value
    end

    def ml2_s
      prepare
      return "#{@env.ml2_s}#{@e1} * #{@e2} evalto #{value} by E-Times {\n" +
             prepare_ml2_s(@e1) +
             prepare_ml2_s(@e2) +
             "  #{@env.ml2_s}#{@e1} times #{@e2} evalto #{value} by B-Times\n" +
             "};\n"
    end
  end

  class TIMES < Struct.new(:e1, :e2)
    def step
      ETIMES.new(e1, e2, @env)
    end

    def ml2_s
      "#{e1} * #{e2}"
    end

    def env! value
      @env = Env.new.env! value
      return self
    end
  end

  class EPLUS < ML2EBase
     def value
      @e1.ml2_value + @e2.ml2_value
    end

    def ml2_s
      prepare
      return "#{@env.ml2_s}#{@e1} * #{@e2} evalto #{value} by E-Plus {\n" +
             prepare_ml2_s(@e1) +
             prepare_ml2_s(@e2) +
             "  #{@env.ml2_s}#{@e1} plus #{@e2} evalto #{value} by B-Plus\n" +
             "};\n"
    end
  end

  class PLUS < Struct.new(:e1, :e2)
    def step
      EPLUS.new(@e1, @e2)
    end

    def ml2_s
      "#{e1} + #{e2}"
    end
  end
end
