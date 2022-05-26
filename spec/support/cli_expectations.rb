require 'rspec/expectations'
require 'warp/dir/app/cli'

module Warp
  module Dir
    module CLIHelper

      def run_command!(arguments)
        argv = arguments.is_a?(Array) ? arguments : arguments.split
        cli  = Warp::Dir::App::CLI.new(argv)
        cli.run
      end

      def validate!(arguments, yield_before_validation: false)
        argv = arguments.is_a?(Array) ? arguments : arguments.split
        cli  = Warp::Dir::App::CLI.new(argv)
        if yield_before_validation && block_given?
          yield(cli)
        end
        cli.validate
        if !yield_before_validation && block_given?
          yield(cli)
        end
        cli.run
      end

      def output_matches(output, expected)
        case expected
        when Regexp
          expected.match(output)
        when String
          output.include?(expected)
        else
          nil
        end
      end
    end
  end
end

RSpec::Matchers.define :output do |*expectations|
  include Warp::Dir::CLIHelper
  match do |actual|
    @response = nil
    @command = "wd #{actual.is_a?(Array) ? actual.join(' ') : actual}"
    expectations.all? do |expected|
      @response = run_command!(actual)
      @response.messages.any? { |m| output_matches(m, expected) }
    end
  end
  failure_message do |actual|
    "#{@command} was supposed to produce something matching or containing:\nexpected: '#{expected}',\n  actual: #{@response.messages}"
  end
  match_when_negated do |actual|
    @response = nil
    @command = "wd #{actual.is_a?(Array) ? actual.join(' ') : actual}"
    expectations.none? do |expected|
      @response = run_command!(actual)
      @response.messages.any? { |m| output_matches(m, expected) }
    end
  end
  failure_message_when_negated do |actual|
    "expected #{actual} not to contain #{expected}, got #{@response}"
  end
end

RSpec::Matchers.define :validate do |expected|
  include Warp::Dir::CLIHelper
  match do |actual|
    if expected == true || expected == false
      yield_before_validation = expected
    end
    expected = block_arg
    if expected.is_a?(Proc)
      begin
        @response = validate!(actual, yield_before_validation: yield_before_validation) do |cli|
          expected.call(cli)
        end
      rescue Exception => e
        $stderr.puts(e.inspect)
        $stderr.puts(e.backtrace.join("\n"))
        raise
      end
    else
      raise TypeError.new('Expected must be a block')
    end
  end
  failure_message do |actual|
    "expected #{actual} to validate that the block evaluates to true"
  end

end

RSpec::Matchers.define :exit_with do |expected|
  include Warp::Dir::CLIHelper

  match do |actual|
    response = run_command!(actual)
    response.code == expected
  end
  match_when_negated do |actual|
    response = run_command!(actual)
    response.code != expected
  end
end
