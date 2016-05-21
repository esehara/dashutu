module Dashutu
  class OperatorBase
    def initialize(e1, e2, e3)
      @e1 = e1
      @e2 = e2
      @e3 = e3
    end

    def to_s
      to_derivation("\n", lastline, name)
    end

    def inspect
      to_S
    end
  end
end
