require 'spec_helper'
require 'blackbox/number'

describe BB::Number do

  describe '.with_delimiter' do
    it "delimits" do
      have = 98765432.98
      want = "98A765A432B98"
      expect(BB::Number.with_delimiter(have, :delimiter => 'A', :separator => 'B' )).to eq(want)
    end
  end

  describe '.with_precision' do
    it "precises" do
      have = 1111.2345
      want = "1A111B23"
      expect(BB::Number.with_precision(have, :precision => 2, :delimiter => 'A', :separator => 'B' )).to eq(want)
    end
  end

  describe '.to_human_size' do

    it "passes through values < base" do
      have = 1023
      want = "1023"
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it "humanizes a kilobyte" do
      have = 1024
      want = "1k"
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it "humanizes a megabyte" do
      have = 1048576
      want = "1M"
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it "humanizes a megabyte (base 1000)" do
      have = 1000000
      want = "1M"
      expect(BB::Number.to_human_size(have, :kilo => 1000)).to eq(want)
    end

    it "humanizes a gigabyte" do
      have = 1024*1024*1024
      want = "1G"
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it "humanizes a terabyte" do
      have = 1024*1024*1024*1024
      want = "1T"
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it "humanizes a petabyte" do
      have = 1024*1024*1024*1024*1024
      want = "1P"
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it "humanizes a exabyte" do
      have = 1024*1024*1024*1024*1024*1024
      want = "1E"
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it "humanizes a zettabyte" do
      have = 1024*1024*1024*1024*1024*1024*1024
      want = "1Z"
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it "humanizes a yottabyte" do
      have = 1024*1024*1024*1024*1024*1024*1024*1024
      want = "1Y"
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it "humanizes 1024.42 yottabytes" do
      have = 1024*1024*1024*1024*1024*1024*1024*1024*1024.42
      want = "1024.42Y"
      expect(BB::Number.to_human_size(have, :precision => 2)).to eq(want)
    end

  end

end

