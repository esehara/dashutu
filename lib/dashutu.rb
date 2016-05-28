require "dashutu/version"
require "dashutu/base"
require "dashutu/evalnats"
require "dashutu/evalml1"
require "dashutu/evalml2"

def to_derivation(f, s, name)
  lsize = if f.size > s.size
            f
          else
            s
          end
  s = (" " * ((lsize.size / 2) - (s.size / 2))) + s
  l = linemaker(lsize, name) + "\n"
  return f + l + s + "\n"
end

def linemaker(l, s)
  linesize = l.size - s.size
  return ("-" * (linesize / 2)) + s + (
           "-" * (linesize / 2))
end

module Dashutu
  extend ML2
  class PZero
    def initialize(n)
      @n = n
    end
  end
end

include Dashutu
