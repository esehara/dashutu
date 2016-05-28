module ML2
  class Env
    def initialize
      @env = []
    end

    def env! value
      @env = value
      return self
    end

    def to_s
      s = @env.map {|k, v| "#{k} = #{v}"}.join(" ")
      return (s.empty? ? "" : s) + " |- "
    end
  end

  class LETIN
    def initialize(name, e1, e2)
      @name = name
      @e1 = e1
      @e2 = e2
      @env = Env.new
    end

    def to_s
      @env.to_s + "let #{@name} = #{@e1} in #{@e2}"
    end

    def env! value
      @env = Env.new.env! value
      return self
    end
  end

  class TIMES < Struct.new(:e1, :e2)
    def to_s
      "#{e1} * #{e2}"
    end
  end

  class PLUS < Struct.new(:e1, :e2)
    def to_s
      "#{e1} + #{e2}"
    end
  end
end
