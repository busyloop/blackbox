require 'spec_helper'
require 'blackbox/version'

describe BB do
  it 'should have a version number' do
    expect(BB::VERSION).not_to be_nil
  end
end

