require 'spec_helper'
require 'warp/dir/response'
module Warp
  module Dir
    RSpec.describe Response do
      let(:response_class) { Response }
      let(:response) { response_class.new }

      it 'should be able to create response' do
        expect(response).to be_kind_of(response_class)
      end

      it 'should allow setting type, code and messages' do
        response.type(Response::SHELL)
        response.message('Hi')
        response.code(200)
        expect(response.type).to eql(Response::SHELL)
        expect(response.message).to eql('Hi')
        expect(response.code).to eql(200)
      end

      describe 'given a response object' do
        before do
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
        describe '#exit' do
          let(:stream) { double }
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

            expect(stream).to receive(:printf).with('Hello').once
            expect(stream).to receive(:printf).with('World').once
            expect(Kernel).to receive(:exit).with(exit_code).once
            response.exit
          end

          it 'should throw an exception when type is undefined' do
            response.configure do
              @type = nil
            end
            expect { response.exit }.to raise_error(ArgumentError)
          end

        end
      end
    end
  end
end
