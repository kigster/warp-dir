require 'spec_helper'

describe Warp::Dir::Commands::List do
  let(:list_command) { Warp::Dir::Commands::List }

  it 'should define a help message' do
    expect(list_command.help).to eql('list            Print all stored warp points')
  end

end
