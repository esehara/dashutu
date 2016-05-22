require 'spec_helper'

describe Dashutu do
  describe ML2 do
    it '#etimes' do
      env = ML2::Env.new
      env.test!
      env.add("x", 3)
      expect(env.etimes("x", "x")).to eq 9
    end

    it "x = 3 |- let x = x * 2 in x + x evalto 12" do
      env = ML2::Env.new
      env.test!
      env.add("x", 3)
      v = env.let("x", env.etimes("x", 2), env.eplus("x", "x"))
      expect(v["x"]).to eq 6
    end
  end
end
