require 'spec_helper'
require 'blackbox/number'

describe BB::Number do
  describe '.with_delimiter' do
    it 'delimits' do
      have = 98_765_432.98
      want = '98A765A432B98'
      expect(BB::Number.with_delimiter(have, delimiter: 'A', separator: 'B')).to eq(want)
    end

    it 'uses sensible defaults' do
      have = 98_765_432.98
      want = '98,765,432.98'
      expect(BB::Number.with_delimiter(have)).to eq(want)
    end

    it 'turns 12345678.05 into "12,345,678.05" by default' do
      have = 12_345_678.05
      want = '12,345,678.05'
      expect(BB::Number.with_delimiter(have)).to eq(want)
    end

    it 'returns nil when input could not be parsed as Float' do
      have = 'not_a_number'
      want = nil
      expect(BB::Number.with_delimiter(have)).to eq(want)
    end

    it 'returns input when input could not be processed' do
      have = 23
      want = have
      # deliberately cause exception with int separator
      expect(BB::Number.with_delimiter(have, separator: -42)).to eq(want)
    end
  end

  describe '.with_precision' do
    it 'precises' do
      have = 1111.2345
      want = '1A111B23'
      expect(BB::Number.with_precision(have, precision: 2, delimiter: 'A', separator: 'B')).to eq(want)
    end

    it 'uses sensible defaults' do
      have = 1111.2345
      want = '1111.235'
      expect(BB::Number.with_precision(have, precision: 3)).to eq(want)
    end

    it 'returns nil when input could not be parsed as Float' do
      have = 'not_a_number'
      want = nil
      expect(BB::Number.with_precision(have, precision: 2)).to eq(want)
    end

    it 'returns input when input could not be processed' do
      have = Float::INFINITY
      want = have
      expect(BB::Number.with_precision(have, precision: 2)).to eq(want)
    end
  end

  describe '.to_human_size' do
    it 'passes through values < base' do
      have = 1023
      want = '1023'
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it 'humanizes a kilobyte' do
      have = 1024
      want = '1k'
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it 'humanizes a megabyte' do
      have = 1_048_576
      want = '1M'
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it 'humanizes a megabyte (base 1000)' do
      have = 1_000_000
      want = '1M'
      expect(BB::Number.to_human_size(have, kilo: 1000)).to eq(want)
    end

    it 'humanizes a gigabyte' do
      have = 1024 * 1024 * 1024
      want = '1G'
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it 'humanizes a terabyte' do
      have = 1024 * 1024 * 1024 * 1024
      want = '1T'
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it 'humanizes a petabyte' do
      have = 1024 * 1024 * 1024 * 1024 * 1024
      want = '1P'
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it 'humanizes a exabyte' do
      have = 1024 * 1024 * 1024 * 1024 * 1024 * 1024
      want = '1E'
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it 'humanizes a zettabyte' do
      have = 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024
      want = '1Z'
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it 'humanizes a yottabyte' do
      have = 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024
      want = '1Y'
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it 'humanizes 1024.42 yottabytes' do
      have = 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024.42
      want = '1024.42Y'
      expect(BB::Number.to_human_size(have, precision: 2)).to eq(want)
    end

    it 'returns nil when input could not be parsed as Float' do
      have = 'not_a_number'
      want = nil
      expect(BB::Number.to_human_size(have)).to eq(want)
    end

    it 'returns input when input could not be processed' do
      have = Float::INFINITY
      want = have
      expect(BB::Number.to_human_size(have)).to eq(want)
    end
  end
end
