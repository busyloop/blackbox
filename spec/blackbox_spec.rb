require 'spec_helper'
require 'blackbox/version'

describe BB do
  it 'should have a version number' do
    BB::VERSION.should_not be_nil
  end
end

