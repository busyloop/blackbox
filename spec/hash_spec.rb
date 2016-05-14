# frozen_string_literal: true
require 'spec_helper'
require 'blackbox/hash'

describe BB::Hash do
  describe '.symbolize_keys' do
    it 'turns all keys into symbols' do
      have = { 'foo' => 1, :bar => 2, 'batz' => 3 }
      want = { foo: 1, bar: 2, batz: 3 }
      expect(BB::Hash.symbolize_keys(have)).to eq(want)
    end

    it 'raises NoMethodError when #to_sym fails for a key' do
      expect do
        have = { 'foo' => 1, 2 => 2, :bar => 3 }
        BB::Hash.symbolize_keys(have)
      end.to raise_error NoMethodError
    end
  end

  describe '.flatten_prop_style' do
    it 'returns flattened hash' do
      have = {
        :a => 1,
        'b' => 2,
        3 => 3,
        :array => [1, 2, 3],
        'nested' => { 'a' => 1, :b => 2, :c => 3 },
        :double_nested => { a: { aa: 1 }, b: { bb: 2 }, c: { cc: 3 } },
        :nested_with_array => { a: { aa: [:a, 'b', 3] }, b: { bb: [:a, 'b', 3] }, c: { cc: [:a, 'b', 3] } }
      }

      want = {
        'a' => 1,
        'b' => 2,
        '3' => 3,
        'array' => '1,2,3',
        'nested.a' => 1,
        'nested.b' => 2,
        'nested.c' => 3,
        'double_nested.a.aa' => 1,
        'double_nested.b.bb' => 2,
        'double_nested.c.cc' => 3,
        'nested_with_array.a.aa' => 'a,b,3',
        'nested_with_array.b.bb' => 'a,b,3',
        'nested_with_array.c.cc' => 'a,b,3'
      }
      expect(BB::Hash.flatten_prop_style(have)).to eq(want)
    end
  end
end
