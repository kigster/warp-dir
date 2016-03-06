require 'spec_helper'
require 'warp/dir/app/response'

RSpec.describe Warp::Dir::App::Response do
  let(:response_class) { ::Warp::Dir::App::Response }
  let(:response) { response_class.instance }
  let(:stream) { double }

  after do
    response.messages.clear
    response.instance_variable_set(:@type, nil)
  end

  describe 'class and type' do
    it 'should be able to create response' do
      expect(response).to be_kind_of(response_class)
    end

    it 'should have constants of correct type' do
      expect(Warp::Dir::App::Response::INFO).to be_kind_of(Warp::Dir::App::Response::Type)
    end
  end

  describe 'accessors' do
    it 'should allow setting type, code and messages' do
      response.type(Warp::Dir::App::Response::INFO)
      response.message('Hi')
      response.code(200)
      expect(response.type).to eql(Warp::Dir::App::Response::INFO)
      expect(response.message).to eql('Hi')
      expect(response.code).to eql(200)
    end
  end

  describe '#configure' do
    describe 'given a response object' do
      before do
        response.instance_variable_set(:@type, nil)
        response.configure do
          type Warp::Dir::App::Response::INFO
          message 'Hello'
          message 'World'
          code 255
        end
      end

      describe '#messages' do
        it 'should concatenate when merged' do
          expect(response.messages).to eql(%w(Hello World))
          expect(response.message).to eql('HelloWorld')
        end
      end
      describe '#type' do
        it 'be equal to the lookup result' do
          expect(response.type).to eql(Warp::Dir::App::Response::RETURN_TYPE[:success])
          expect(response.type).to eql(Warp::Dir::App::Response::INFO)
        end
      end
      describe '#code' do
        it 'should be as it was configured' do
          expect(response.code).to eql(255)
        end
      end
    end
  end


  describe '#exit' do
    let(:exit_code) { 199 }
    let(:fake_type) { Warp::Dir::App::Response::Type.new(exit_code, stream) }
    before do
      Warp::Dir::App::Response.enable_exit!
    end
    after do
      Warp::Dir::App::Response.disable_exit!
    end

    describe 'without specifying type' do
      it 'should throw an exception' do
        expect { response.exit! }.to raise_error(ArgumentError)
      end
    end

    describe 'when type is user output' do
      before do
        response.type(fake_type)
      end

      it 'should properly format messages for eval' do
        expect(stream).to receive(:printf).with(%Q{printf 'Hello\n'}).once
        expect(stream).to receive(:printf).with(%Q{printf 'World\n'}).once
        response.configure do
          message 'Hello'
          message 'World'
        end
        response.print
      end
      it 'should properly exit via Kernel' do
        expect(Kernel).to receive(:exit).with(exit_code).once
        response.configure do
          code 199
        end
        response.exit!
      end
    end

    describe 'when type is shell' do
      before do
        @stream                                = Warp::Dir::App::Response::SHELL.stream
        Warp::Dir::App::Response::SHELL.stream = stream
      end
      after do
        Warp::Dir::App::Response::SHELL.stream = @stream
      end

      it 'should return proper exit code for shell commands' do
        response.type(Warp::Dir::App::Response::SHELL)
        response.configure do
          message 'ls -al'
          code 1231 # this should be ignored
        end
        expect(stream).to receive(:printf).with('ls -al;').once
        expect(Kernel).to receive(:exit).with(2).once
        response.print.exit!
      end
    end
  end
end
