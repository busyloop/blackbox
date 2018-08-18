# frozen_string_literal: true

require 'spec_helper'
require 'blackbox/string'

describe BB::String do
  describe '.strip_ansi' do
    it 'strips a few common escape sequences' do
      have = "\e[31;1mX\e[AY\e[2JZ"
      want = 'XYZ'
      expect(BB::String.strip_ansi(have)).to eq(want)
    end
  end
end
