require 'spec_helper'

describe Dashutu do
  describe ML2 do
    it 'x = 3 |- let x = x * 2 in x + x evalto 12' do
      s = ML2::LETIN.new(
        "x",
        ML2::TIMES.new("x", 2),
        ML2::PLUS.new("x", "x"))
          .env!([["x", 3]]).to_s
      expect(s).to eq('x = 3 |- let x = x * 2 in x + x')
    end
  end
end
