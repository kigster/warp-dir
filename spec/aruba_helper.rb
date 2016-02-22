require 'aruba/rspec'
require 'spec_helper'

RSpec.configure do |config|
  config.include ArubaDoubles

  config.before :each do
    Aruba::RSpec.setup
  end

  config.after :each do
    Aruba::RSpec.teardown
  end
end
