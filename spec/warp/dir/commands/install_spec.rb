require 'spec_helper'
require 'support/cli_expectations'
require 'warp/dir/formatter'

RSpec.describe Warp::Dir::Command::Install do

  let(:commander) { Warp::Dir.commander }
  let(:install) { Warp::Dir::Command::Install.new(store) }

  describe '#run' do
    include_context :fixture_file
    include_context :initialized_store

    context 'when shell files do not exist' do
      it 'should return :error type response' do
        expect('install --dotfile ~/.do_not_exist').to output(/not found/)
      end
    end
  end
end
