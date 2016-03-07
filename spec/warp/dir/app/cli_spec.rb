require 'spec_helper'
require 'support/cli_expectations'
require 'warp/dir'
require 'warp/dir/config'
require 'warp/dir/app/cli'
require 'pp'
require 'fileutils'

RSpec.describe Warp::Dir::App::CLI do
  include_context :fixture_file
  include_context :initialized_store

  let(:config_args) { ['--config', config.warprc] }
  let(:warprc) { config_args.join(' ') }

  describe 'when parsing argument list' do
    let(:cli) { Warp::Dir::App::CLI.new(argv) }
    before do
      cli.config = config
    end

    describe 'with suffix flags' do
      subject { cli.send(:extract_suffix_flags, argv) }
      describe 'and with at leats two arguments' do
        let(:argv) { 'command argument --flag1 --flag2 -- --suffix1 --suffix2 suffix-argument'.split(' ')}
        it 'extracts them well' do
          should eql(%w(--suffix1 --suffix2 suffix-argument))
        end
      end
    end

    describe 'with only one argument' do
      let(:result) { cli.send(:shift_non_flag_commands) }

      describe "that's a list command" do
        let(:argv) { %w(list --verbose) }

        it 'should assign the command' do
          expect(cli.argv).to eql(%w(list --verbose))
          expect(result[:command]).to eql(:list)
          expect(cli.argv).to eql(['--verbose'])
        end
      end

      describe "that's a warp point" do
        let(:argv) { %w(awesome-point) }

        it 'should default to the :warp command' do
          expect(result[:command]).to eql(:warp)
          expect(result[:point]).to eql(:'awesome-point')
          expect(cli.argv).to be_empty
        end
      end
    end

    describe 'with two command args' do
      let(:argv) { %w(add mypoint) }
      let(:result) { cli.send(:shift_non_flag_commands) }

      it 'should interpret as a command and a point' do
        expect(result[:command]).to eql(:add)
        expect(result[:point]).to eql(:mypoint)
        expect(cli.argv).to be_empty
      end
    end
  end

  describe 'when parsing flags' do
    describe 'and found --help' do
      let(:argv) { ['--help', *config_args] }
      it 'should print the help message' do
        expect(argv).to output(/<point>/, /Usage:/)
        expect(argv).not_to output(/^cd /)
      end
      it 'should exit with zero status' do
        expect(argv).to exit_with(0)
      end
    end

    describe 'and a flag is no found' do
      let(:argv) { [ '--boo mee --moo', *config_args ] }
      it 'should report invalid option' do
        expect(argv).to output( /unknown option/)
      end
    end

    describe 'when an exception error occurs' do
      let(:argv) { [ %w(boo dkk --debug), *config_args ].flatten }
      context 'and --debug is given' do
        it 'should print backtrace' do
          expect(argv.join(' ')).to eql('boo dkk --debug --config /tmp/warprc')
          expect(STDERR).to receive(:puts).twice
          expect(argv).to validate(false) { |cli|
            expect(cli.config.debug).to be_truthy
          }
        end
      end
    end
  end

  describe 'when running command' do
    describe 'without a parameter' do
      describe 'such as list' do
        let(:argv) { ['list', *config_args] }

        it 'should return listing of all points' do
          expect("list #{warprc}").to output %r{log  ->  /var/log}
          expect("list #{warprc}").to output %r{tmp  ->  /tmp}
        end

        it 'should exit with zero status' do
          expect("list #{warprc}").to exit_with(0)
        end
      end
    end

    describe 'with a point arg, such as ' do
      let(:wp_name) { store.last.name }
      let(:wp_path) { store.last.path }
      let(:warp_args) { "#{wp_name} #{warprc}" }

      describe 'warp <point>' do
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

      describe 'remove <point>' do
        let(:warp_args) { "remove #{wp_name} #{warprc}" }

        it 'should show that point is removed ' do
          expect(warp_args).to output(/has been removed/)
        end
        it 'should change warp point count ' do
          expect(store.size).to eq(2)
          expect {
            expect(warp_args).to validate { |cli|
              expect(cli.config.point).to eql(point.name)
              expect(cli.config.command).to eql(:remove)
            }
            store.restore!
          }.to change(store, :size).by(-1)
          expect(store.size).to eq(1)
        end
      end

      describe 'add <point>' do
        context 'when point exists' do
          context 'without --force flag' do
            let(:warp_args) { "add #{wp_name} #{warprc}" }

            it 'should show error without' do
              expect(warp_args).to output(/already exists/)
              expect(warp_args).to exit_with(1)
            end
          end
          context 'with --force' do
            let(:warp_args) { "add #{wp_name} #{warprc} --force" }
            it 'should overwrite existing point' do

              expect(Warp::Dir.pwd).to_not eql(wp_path)

              existing_point = store[wp_name]
              expect(existing_point).to be_kind_of(Warp::Dir::Point)
              expect(existing_point.path).to eql(wp_path)

              expect {
                response = expect(warp_args).to validate { |cli|
                  expect(cli.config.point).to eql(point.name)
                  expect(cli.config.command).to eql(:add)
                  expect(cli.store[point.name]).to_not be_nil
                }
                expect(response.type).to eql(Warp::Dir::App::Response::INFO), response.message
                store.restore!
                updated_point = store[wp_name]
                expect(updated_point.relative_path).to eql(Warp::Dir::pwd)
              }.to_not change(store, :size)

            end
          end
        end
      end

      describe 'ls <point>' do
        context 'no flags' do
          let(:warp_args) { "ls #{wp_name} #{warprc}" }
          it 'should default to -al' do
            expect(warp_args).to output(%r{total \d+\n}, %r{ warprc\n})
          end
        end
        context '-- -l' do
          let(:warp_args) { "ls #{wp_name} #{warprc} -- -l" }
          it 'should extract flags' do
            expect(warp_args).to validate { |cli|
              expect(cli.flags).to eql(['-l'])
            }
          end
          it 'should ls folder in long format' do
            expect(warp_args).to output(%r{total \d+\n}, %r{ warprc\n})
          end
        end
        context '-- -1' do
          let(:warp_args) { "ls #{wp_name} #{warprc} -- -1" }
          it 'should not list directory in long format' do
            expect(warp_args).not_to output(%r{total \d+\n}, %r{ warprc\n})
          end
        end
        context '-- -elf' do
          let(:warp_args) { "ls #{wp_name} #{warprc} -- -alF" }
          [%r{total \d+\n}, %r{ warprc\n}].each do |reg|
            it "should list directory and match #{reg}" do
              expect(warp_args).to output(reg)
            end
          end
        end
      end
    end
  end
end
