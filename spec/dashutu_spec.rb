require 'spec_helper'

def result s
  puts "-------------------------"
  puts s.ml2_s
  puts "-------------------------"
end

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
        puts "-------------------------"
        puts s.step.ml2_s
        puts "-------------------------"
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

      it 'x = 3, y = 4 |- x * y evalto 12' do
        s = ML2::TIMES.new("x", "y").env!([["x", 4], ["y", 3]]).step
        puts "-------------------------"
        puts s.ml2_s
        puts "-------------------------"
      end
    end

    it 'x = 3 |= x - 3 evalto 0' do
      s = ML2::MINUS.new("x", 3).env!([["x", 3]]).step
      puts "----------------------"
      puts s.ml2_s
      puts "----------------------"
    end

    it 'let sq = fun x -> x * x in sq 3 + sq 4 evalto 25' do
      s = ML2::LETIN.new(
        "sq",
        ML2::FUN.new("x", ML2::TIMES.new("x", "x")),
        ML2::PLUS.new(
          ML2::CALL.new("sq", 3),
          ML2::CALL.new("sq", 4)))
      puts s.ml2_s
      result s.step
    end
  end
end
