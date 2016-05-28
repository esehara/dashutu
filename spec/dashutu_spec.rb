require 'spec_helper'

describe Dashutu do
  describe ML2 do
    describe 'x = 3 |- let x = x * 2 in x + x' do
      it 'show x = 3 |- let x = x * 2 in x + x' do
        s = ML2::LETIN.new(
          "x",
          ML2::TIMES.new("x", 2),
          ML2::PLUS.new("x", "x"))
            .env!([["x", 3]])
        expect(s.ml2_s).to eq('x = 3 |- let x = x * 2 in x + x')
      end

      it '|- 2 * 2 evalto 4' do
        s = ML2::TIMES.new(2, 2).step
        puts "-------------------------"
        puts s.ml2_s
        puts "-------------------------"
        expect(s.class).to eq(ML2::ETIMES)
      end

      it 'x = 3 |- x * 3 evalto 12' do
        s = ML2::TIMES.new("x", 2).env!([["x", 4]]).step
        puts "-------------------------"
        puts s.ml2_s
        puts "-------------------------"
      end
    end
  end
end
