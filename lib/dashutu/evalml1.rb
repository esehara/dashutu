module Dashutu
  include OperatorBase
  module M1
    class BLT < OperatorBase
      attr_accessor :i3

      def eval?
        true
      end

      def name
        " by B-Lt"
      end

      def initialize(i1, i2)
        @i1 = i1
        @i2 = i2
        @i3 = i1 < i2
      end

      def lastline
        "#{@i1} less than #{@i2} is #{@i3}"
      end

      def to_s
        to_derivation("\n", lastline, name)
      end
    end

    class BTIMES < OperatorBase
      attr_accessor :i3

      def eval?
        true
      end

      def name
        " by B-Times"
      end

      def initialize(i1, i2)
        @i1 = i1
        @i2 = i2
        @i3 = i1 * i2
      end

      def lastline
        "#{@i1} times #{@i2} is #{@i3}"
      end

      def to_s
        to_derivation("\n", lastline, name)
      end
    end

    class BMINUS < OperatorBase
      attr_accessor :i3

      def eval?
        true
      end

      def name
        " by B-Minus"
      end

      def initialize(i1, i2)
        @i1 = i1
        @i2 = i2
        @i3 = i1 - i2
      end

      def lastline
        "#{@i1} minus #{@i2} is #{@i3}"
      end

      def to_s
        to_derivation("\n", lastline, name)
      end
    end

    class BPLUS
      attr_accessor :i3

      def eval?
        true
      end

      def initialize(i1, i2)
        @i1 = i1
        @i2 = i2
        @i3 = i1 + i2
      end

      def name
        " by B-Plus "
      end

      def lastline
        "#{@i1} plus #{@i2} is #{@i3}"
      end

      def to_s
        to_derivation("\n", lastline, name)
      end
    end

    class EINT
      attr_accessor :i

      def name
        " by E-Int "
      end

      def eval?
        true
      end

      def initialize(i)
        @i = i
      end

      def lastline
        "#{@i} evalto #{@i}"
      end

      def to_s
        to_derivation("\n", lastline, NAME)
      end

      def inspect
        to_s
      end
    end

    class EIFT < OperatorBase
      def name
        " by E-Ift "
      end

      def lastline
        "if #{@e1.e3.i3} than #{@e2.i} else #{@e3.i} evalto #{@e2.i}"
      end

      def calc_equal?
        if
          @e1.i3
        then
          @e2.i
        else
          @e3.i
        end == @e2
      end
    end

    class EIFF < OperatorBase
      def name
        " by E-IfF"
      end

      def lastline
        "if #{@e1.e3.i3} then #{@e2.i} else #{@e3.i} evalto #{@e3.i}"
      end

      def calc_equal?
        if
          @e1.i3
        then
          @e2.i
        else
          @e3.i
        end == @e3
      end
    end

    class ELT < OperatorBase
      attr_accessor :e3

      def initialize(e1, e2)
        @e1 = refrect(e1)
        @e2 = refrect(e2)
        @e3 = BLT.new(@e1.i, @e2.i)
      end

      def name
        "by E-Lt"
      end

      def lastline
        "#{@e1.i} < #{@e2.i} evalto #{@e3.i3}"
      end

      def calc_equal?
        @e1.i < @e2.i == @e3.i3
      end
    end

    class EMINUS < OperatorBase

      def initialize(e1, e2)
        @e1 = refrect(e1)
        @e2 = refrect(e2)
        @e3 = BMINUS.new(@e1.i, @e2.i)
      end

      def name
        "by E-Minus"
      end

      def lastline
        "#{@e1.i} - #{@e2.i} evalto #{@e3.i3}"
      end

      def calc_equal?
        @e1.i - @e2.i == @e3.i3
      end
    end

    class ETIMES < OperatorBase

      def initialize(e1, e2)
        @e1 = refrect(e1)
        @e2 = refrect(e2)
        @e3 = BTIMES.new(@e1.i, @e2.i)
      end

      def name
        "by E-Times"
      end

      def lastline
        "#{@e1.i} * #{@e2.i} evalto #{@e3.i3}"
      end

      def calc_equal?
        @e1.i * @e2.i == @e3.i3
      end
    end

    class EPLUS < OperatorBase
      def name
        "by E-Plus"
      end

      def initialize(e1, e2)
        @e1 = refrect(e1)
        @e2 = refrect(e2)
        @e3 = BPLUS.new(@e1.i, @e2.i)
      end

      def calc_equal?
        @e1.i + @e2.i == @e3.i3
      end

      def lastline
        "#{@e1.i} + #{@e2.i} evalto #{@e3.i3}"
      end
    end
  end
end
