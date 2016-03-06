require 'spec_helper'
require 'support/cli_expectations'
require 'warp/dir'
require 'warp/dir/config'
require 'warp/dir/app/cli'
require 'pp'

RSpec.describe Warp::Dir::App::CLI do
  include_context :fixture_file
  include_context :initialized_store

  let(:config_args) { ['--config', config.warprc] }
  let(:warprc) { config_args.join(' ') }

  describe 'arg list' do
    let(:cli) { Warp::Dir::App::CLI.new(argv) }
    before do
      cli.config = config
    end

    let(:result) { cli.send(:shift_non_flag_commands) }
    describe 'when only one argument passed' do

      describe 'and is a command' do
        let(:argv) { %w(list --verbose) }

        it 'invokes list command message' do
          expect(cli.argv).to eql(%w(list --verbose))
          expect(result[:command]).to eql(:list)
          expect(cli.argv).to eql(['--verbose'])
        end
      end
      describe 'and is a warp point' do
        let(:argv) { %w(awesome-point) }

        it 'defaults to the :warp command' do
          expect(result[:command]).to eql(:warp)
          expect(result[:point]).to eql(:'awesome-point')
          expect(cli.argv).to be_empty
        end
      end
    end
    describe 'when two non-flag arguments passed' do
      let(:argv) { %w(add mypoint) }

      it 'interprets as a command and a point' do
        expect(result[:command]).to eql(:add)
        expect(result[:point]).to eql(:mypoint)
        expect(cli.argv).to be_empty
      end
    end
  end

  describe 'flags' do
    describe '--help' do
      let(:argv) { ['--help', *config_args ] }
      it 'prints help message' do
        expect("--help #{warprc}").to output(/<point>/, /Usage:/)
        expect("--help #{warprc}").not_to output(/^cd /)
      end

      it 'should exit with zero status' do
        expect("--help #{warprc}").to exit_with(0)
      end
    end
  end

  describe 'commands' do
    describe 'list' do
      let(:argv) { ['list', *config_args] }

      it 'should return listing of the warp points' do
        expect("list #{warprc}").to output %r{log  ->  /var/log}
        expect("list #{warprc}").to output %r{tmp  ->  /tmp}
      end

      it 'should exit with zero status' do
        expect("list #{warprc}").to exit_with(0)
      end
    end

    describe 'warp' do
      let(:wp_name) { store.last.name }
      let(:wp_path) { store.last.path }
      let(:warp_args) { "#{wp_name} #{warprc}" }

      it "should return response with a 'cd' to a warp point" do
        warp_point = wp_name
        expect(warp_args).to validate { |cli|
          expect(cli.config.point).to eql(warp_point)
          expect(cli.config.command).to eql(:warp)
          expect(cli.store[warp_point]).to eql(Warp::Dir::Point.new(wp_name, wp_path))
        }
        expect(warp_args).to output("cd #{wp_path}")
      end
    end
  end
end
