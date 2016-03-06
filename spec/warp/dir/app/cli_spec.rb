require 'spec_helper'
require 'warp/dir'
require 'warp/dir/config'
require 'warp/dir/app/cli'

RSpec.describe Warp::Dir::App::CLI do
  include_context :fixture_file

  let(:cli) { Warp::Dir::App::CLI.new(argv) }

  describe 'flags' do
    describe '--help' do
      let(:argv) { %w(--help) }
      it 'prints help message' do
        response = cli.run
        expect(response.type).to eql(Warp::Dir::App::Response::INFO)
        expect(response.messages.first).to eql(Warp::Dir::Command::Help::USAGE)
      end
      it 'should exit with zero status' do
        response = cli.run
        expect(response.code).to eql(0)
      end
    end
  end

  describe 'commands' do

    describe 'warp directory' do
      context 'shell execution context' do
        it 'returns exit code of 111' do

        end
        it 'returns cd command for the shell eval' do

        end
      end

      context 'when warp point was not found' do
        it 'returns exit code of 0' do

        end

        it 'prints an error message' do

        end
      end
    end

    describe 'add warp point' do
      it ''


      describe 'remove warp point' do


      end

      describe 'list warp points' do

      end
    end
  end
end
