module ML2Helper
  def to_copl_ml2
    self.to_s + " evalto " + self.to_s
  end

  def lastline
    to_copl_ml2
  end

  def ml2_value
    self
  end
end

class String
  attr_accessor :ml2_value
  def ml2_value= x
    @ml2_value = x
  end

  def to_copl_ml2
    self + " evalto " + self.ml2_value.to_s
  end

  def lastline
    to_copl_ml2
  end

  def ml2_name
    " by E-Var1"
  end
end

class Fixnum
  include ML2Helper
  def ml2_name
    " by E-Int"
  end
end

class TrueClass
  include ML2Helper
  def ml2_name
    " by E-Bool"
  end
end

module Dashutu
  module ML2
    class OperatorBase
      def show
        to_derivation(fistline, lastline, name)
      end
    end

    class Env
      attr_accessor :debug

      def initialize
        @env = Hash.new
        @debug = false
      end

      def test!
        @debug = true
      end

      def add(k, v)
        @env[k] = v
        self
      end

      def env
        to_env @env
      end

      def to_env x
        (x.map {|k, v| "#{k} = #{v}" }.join ",") + " |-"
      end

      def to_s
        env
      end

      def etimes(e1, e2, value=false)
        -> {
          e1 = to_var(e1)
          e2 = to_var(e2)
          result = e1.ml2_value * e2.ml2_value
          exp = "#{env} #{e1} * #{e2} evalto #{result}"
          return exp + " by E-Times ", result if value
          return result if debug

          to_derivation(
            "#{e1.lastline} #{e1.ml2_name} , #{e2.lastline} #{e2.ml2_name} , #{e1.ml2_value} times #{e2.ml2_value} is #{result} by B-Times\n",
            "#{exp}\n",
            " by E-Times ")
        }
      end

      def eplus(e1, e2, value=false)
        -> {e1 = to_var(e1)
            e2 = to_var(e2)
            result = e1.ml2_value + e2.ml2_value
            exp = "#{env} #{e1.ml2_value} + #{e2.ml2_value} evalto #{result}"
            return exp + " by E-Plus ", result  if value
            return result if debug

            to_derivation(
              "#{e1.lastline} #{e1.ml2_name} , #{e2.lastline} #{e2.ml2_name} , #{e1.ml2_value} plus #{e2.ml2_value} is #{result} by B-Plus\n",
              "#{exp}\n",
              " by E-Plus ")
        }
      end

      def let(name, e1, e2)
        exp1, e1 = e1[]
        e1 = to_var(e1)
        prev_env = @env.clone
        add(name, e1)

        exp2, e2 = e2[]
        e2 = to_var(e2)
        return @env if debug

        to_derivation(
          "#{exp1} , #{exp2}\n",
          "#{to_env(prev_env)} let #{name} = #{e1.ml2_value} in #{e2.ml2_value}\n",
          " by E-Let")
      end

      private
      def to_var(x)
        if x.is_a? String
          x.ml2_value = @env[x]
        end
        x
      end
    end
  end
end
