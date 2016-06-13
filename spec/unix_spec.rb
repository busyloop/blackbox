# frozen_string_literal: true
require 'spec_helper'
require 'blackbox/unix'

describe BB::Unix do
  describe '.run_each' do
    it 'exits on failure by default' do
      expect {
        expect {
          BB::Unix.run_each('false')
        }.to output().to_stdout
      }.to raise_error(SystemExit)
    end

    it 'echos to stdout by default' do
      expect {
        BB::Unix.run_each('true')
      }.to output(/true/).to_stdout
    end

    it 'quiet success in quiet mode' do
      expect {
        BB::Unix.run_each(":return\n:quiet\ntrue")
      }.to output('').to_stdout
    end

    it 'loud failure in quiet mode' do
      expect {
        BB::Unix.run_each(":return\n:quiet\nfalse")
      }.to output(/exit 1: false/).to_stdout
    end
  end
end
