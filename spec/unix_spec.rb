# frozen_string_literal: true
require 'spec_helper'
require 'blackbox/unix'

describe BB::Unix do
  describe '.run_each' do
    it 'exits on failure by default' do
      expect do
        expect do
          BB::Unix.run_each('false')
        end.to output.to_stdout
      end.to raise_error(SystemExit)
    end

    it 'echos to stdout by default' do
      expect do
        BB::Unix.run_each('true')
      end.to output(/true/).to_stdout
    end

    it 'quiet success in quiet mode' do
      expect do
        BB::Unix.run_each(":return\n:quiet\ntrue")
      end.to output('').to_stdout
    end

    it 'loud failure in quiet mode' do
      expect do
        BB::Unix.run_each(":return\n:quiet\nfalse")
      end.to output(/exit 1: false/).to_stdout
    end
  end
end
