class String
  def ml2_value
    self
  end
end


class Fixnum
  def ml2_value
    self
  end

  def step
    self
  end

  def ml2_exp
    self
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
      Var1.new(k, @env[-1].clone[1], self)
    end

    def add! k, v
      @env = @env.clone
      @env << [k, v]
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

    def ml2_s_local
      s = @env.map {|k, v| "#{k}=#{v}"}.join(",")
    end
  end

  class LETIN
    def initialize(name, e1, e2)
      @name = name
      @e1 = e1
      @e2 = e2
      @env = Env.new
    end

    def env=(env)
      @env = env
    end

    def ml2_s
      @env.ml2_s + "let #{@name} = #{@e1.ml2_exp} in #{@e2.ml2_s}"
    end

    def env! value
      @env = Env.new.env! value
      return self
    end

    def step?
      true
    end

    def step
      ELETIN.new(@name, @e1, @e2, @env)
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
      if e1.is_a?(CALL)
        if e1.env.nil?
          env = @env.clone
          e1 = e1.clone
          e1.env = env
        end
        e1 = e1.step
      elsif e1.is_a? String
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

  class CALL
    attr_accessor :env

    def initialize(name, params)
      @name = name
      @param = params
    end

    def ml2_s
      "#{@name} #{@param}"
    end

    def ml2_exp
      ml2_s
    end

    def to_s
      ml2_s
    end

    def step
      EAPP.new(@name, @param, @env)
    end

    def ml2_value
      return step.value
    end
  end

  class EAPP < ML2EBase
    def initialize(e1, e2, env)
      @env = env
      @e1 = varize e1
      @e2 = varize e2
      local_env = env.clone
      local_env.add!(@e1.e2.param, @e2)
      exp = @e1.e2.exp
      @e1.e2.exp = exp.class.new(exp.e1, exp.e2)
      @e1.e2.exp.env = local_env
    end

    def ml2_exp
      "#{@e1.ml2_exp} #{@e2.ml2_exp}"
    end

    def ml2_s
      prepare
      return "#{@env.ml2_s}#{@e1.ml2_exp} #{@e2.ml2_exp} evalto #{ml2_value} by E-App {\n" +
             prepare_ml2_s(@e1) +
             prepare_ml2_s(@e2) +
             "};\n"
    end

    def ml2_value
      @e1.e2.exp.step.ml2_value
    end
  end

  class FUN
    def initialize(param, exp)
      @param = param
      @exp = exp
      @env = Env.new
    end

    def env= env
      @env = env
    end

    def env! lst
      @env = Env.new.env! lst
      self
    end

    def step
      EFUN.new(@param, @exp, @env)
    end

    def ml2_s
      "fun #{@name} -> #{@exp.ml2_exp}"
    end
  end

  class EFUN
    attr_accessor :param, :exp
    def initialize(param, exp, env)
      @param = param
      @exp = exp
      @env = env
    end

    def ml2_s_rep
      "fun #{@param.ml2_value} -> #{@exp.ml2_exp}"
    end

    def ml2_s
      return "#{@env.ml2_s}#{ml2_s_rep} evalto (#{@env.ml2_s_local})[#{ml2_s_rep}] by E-Fun {};"
    end

    def ml2_exp
      "(#{@env.ml2_s_local})[fun #{@param} -> #{@exp.ml2_exp}]"
    end

    def ml2_value
      self
    end

    def to_s
      ml2_exp
    end
  end

  class ELETIN < ML2EBase
    def initialize(name, e1, e2, env)
      e1.env = env if !e1.is_a? Fixnum
      @env = env.clone
      @e1 = e1.step
      env = env.clone

      @name = name
      env.add!(@name, @e1.ml2_value)
      e2.env = env if !e2.is_a? Fixnum
      @e2 = e2.step
    end

    def ml2_s
      prepare
      return "#{@env.ml2_s}let #{@name} = #{@e1.ml2_exp } in #{@e2.ml2_exp} evalto #{ml2_value} by E-Let {\n" +
             prepare_ml2_s(@e1) +
             prepare_ml2_s(@e2) +
             "};\n"
    end

    def ml2_value
      prepare
      @e2.ml2_value
    end

    def ml2_exp
      prepare
      "let #{@name} = #{@e1.ml2_exp} in #{@e2.ml2_exp}"
    end
  end

  class Var2
    def initialize(e1, e2, env)
      @e1 = e1
      @e2 = e2
      @env = env
    end

    def e2
      prepare
      @e1.e2
    end

    def prepare
      next_env = @env.clone
      next_env.pop!
      @e1 = next_env.var1 @e1
    end

    def ml2_s
      prepare
      "#{@env.ml2_s}#{@e1} evalto #{@e2} by E-Var2 {\n" +
        "  #{@e1.ml2_s} \n" +
        "\n};"
    end

    def ml2_value
      @e2
    end

    def ml2_exp
      to_s
    end

    def to_s
      @e1.to_s
    end
  end

  class Var1
    attr_accessor :e2
    def initialize(e1, e2, env)
      @e1 = e1
      @e2 = e2
      @env = env
    end

    def ml2_s
      "#{@env.ml2_s}#{@e1} evalto #{@e2} by E-Var1 {};"
    end

    def ml2_value
      @e2
    end

    def ml2_exp
      to_s
    end

    def to_s
      if @e1.is_a? Var1
        @e1.to_s
      else
        @e1
      end
    end
  end

  class ETIMES < ML2EBase
    def ml2_value
      prepare
      @e1.ml2_value * @e2.ml2_value
    end

    def ml2_s
      prepare
      return "#{@env.ml2_s}#{@e1} * #{@e2} evalto #{ml2_value} by E-Times {\n" +
             prepare_ml2_s(@e1) +
             prepare_ml2_s(@e2) +
             "  #{@e1.ml2_value} times #{@e2.ml2_value} is #{ml2_value} by B-Times {};\n" +
             "};\n"
    end

    def ml2_exp
      prepare
      "#{@e1.ml2_exp} * #{@e2.ml2_exp}"
    end
  end

  class TIMES
    attr_accessor :e1, :e2, :env

    def initialize(e1, e2)
      @e1 = e1
      @e2 = e2
    end

    def step
      ETIMES.new(@e1, @e2, @env)
    end

    def ml2_s
      "#{@e1} * #{@e2}"
    end

    def env! value
      @env = Env.new.env! value
      self
    end

    def ml2_exp
      ml2_s
    end
  end

  class EMINUS < ML2EBase
    def ml2_value
      prepare
      @e1.ml2_value - @e2.ml2_value
    end

    def ml2_s
      prepare
      return "#{@env.ml2_s}#{@e1} - #{@e2} evalto #{ml2_value} by E-Minus {\n" +
             prepare_ml2_s(@e1) +
             prepare_ml2_s(@e2) +
             "  #{@e1.ml2_value} minus #{@e2.ml2_value} is #{ml2_value} by B-Minus {};\n" +
             "};\n"
    end

    def ml2_exp
      prepare
      "#{@e1.ml2_exp} - #{@e2.ml2_exp}"
    end
  end

  class MINUS
    attr_accessor :env

    def initialize e1, e2
      @e1 = e1
      @e2 = e2
    end

    def env! env
      @env = Env.new.env! env
      self
    end

    def step
      EMINUS.new(@e1, @e2, @env)
    end

    def ml2_s
      "#{@e1} - #{@e2}"
    end
  end

  class EPLUS < ML2EBase
    def ml2_value
      prepare
      @e1.ml2_value + @e2.ml2_value
    end

    def ml2_s
      prepare
      return "#{@env.ml2_s}#{@e1} + #{@e2} evalto #{ml2_value} by E-Plus {\n" +
             prepare_ml2_s(@e1) +
             prepare_ml2_s(@e2) +
             "  #{@e1.ml2_value} plus #{@e2.ml2_value} is #{ml2_value} by B-Plus {};\n" +
             "};\n"
    end

    def ml2_exp
      prepare
      "#{@e1.ml2_exp} + #{@e2.ml2_exp}"
    end
  end

  class PLUS
    attr_accessor :env

    def initialize e1, e2
      @e1 = e1
      @e2 = e2
    end

    def env! env
      @env = Env.new.env! env
      self
    end

    def step
      EPLUS.new(@e1, @e2, @env)
    end

    def ml2_exp
      ml2_s
    end

    def ml2_s
      "#{@e1} + #{@e2}"
    end
  end
end
