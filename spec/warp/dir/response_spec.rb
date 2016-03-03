require 'spec_helper'
require 'warp/dir/response'
module Warp
  module Dir
    RSpec.describe Response do
      let(:response_class) { Response }
      let(:response) { response_class.new }
      let(:stream) { double }

      it 'should be able to create response' do
        expect(response).to be_kind_of(response_class)
      end

      it 'should allow setting type, code and messages' do
        response.type(Response::INFO)
        response.message('Hi')
        response.code(200)
        expect(response.type).to eql(Response::INFO)
        expect(response.message).to eql('Hi')
        expect(response.code).to eql(200)
      end

      describe 'given a response object' do
        before do
          response.instance_variable_set(:@type, nil)
          response.configure do
            type Response::INFO
            message 'Hello'
            message 'World'
            code 255
          end
        end

        describe '#define' do
          it 'should have configured code and message' do
            expect(response.type).to eql(Response::RETURNS[:success])
            expect(response.type).to eql(Response::INFO)
            expect(response.messages).to eql(%w(Hello World))
            expect(response.message).to eql('HelloWorld')
            expect(response.code).to eql(255)
          end
        end
      end

      describe '#exit' do
        let(:exit_code) { 199 }
        let(:fake_type) { Response::ResponseType.new(exit_code, stream) }
        before do
          Response.enable_exit!
        end
        after do
          Response.disable_exit!
        end
        it 'should properly call the kernel and print the messages' do
          response.type(fake_type)
          response.configure do
            message 'Hello'
            message 'World'
            code 199
          end
          expect(stream).to receive(:printf).with('Hello').once
          expect(stream).to receive(:printf).with('World').once
          expect(Kernel).to receive(:exit).with(exit_code).once
          response.exit
        end

        it 'should throw an exception when type is undefined' do
          expect { response.exit }.to raise_error(ArgumentError)
        end

        it 'should return proper exit code for shell commands' do
          response.type(Response::SHELL)
          response.configure do
            message 'ls -al'
            code 1231
          end
          expect(STDOUT).to receive(:printf).with("ls -al\n").once
          expect(Kernel).to receive(:exit).with(2).once
          response.exit
        end
      end

      describe 'SHELL' do
        before do
          @stream                = Response::SHELL.stream
          Response::SHELL.stream = stream
        end
        after do
          Response::SHELL.stream = @stream
        end

        it 'should print enclosed in printf for shell' do

        end

      end
    end
  end
end
