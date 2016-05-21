module Dashutu
  def z
    Z.new
  end

  class Z
    def initialize
      @succ = 0
    end

    def s
      @succ += 1
      return self
    end

    def to_s
      p = '(S' * @succ
      l = ')' * @succ
      if @succ == 0
        'Z'
      else
        p + '(Z)' + l
      end
    end

    def inspect
      to_s
    end
  end

  class PZERO
    attr_accessor :e1, :e2

    NAME = "[P-Zero]"
    def eval?
      true
    end

    def initialize(i)
      @e1 = Z.new
      @e2 = i
    end

    def to_s
      to_derivation("\n", "Z plus #{@e2} is #{@e2}", NAME)
    end

    def inspect
      to_s
    end
  end
end
