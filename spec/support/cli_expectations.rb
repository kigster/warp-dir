require 'rspec/expectations'
require 'warp/dir/app/cli'
require 'rspec/expectations'

module Warp
  module Dir
    module CLIHelper

      def run_command!(arguments)
        argv = arguments.is_a?(Array) ? arguments : arguments.split(' ')
        cli  = Warp::Dir::App::CLI.new(argv)
        cli.run
      end

      def validate!(arguments, yield_before_validation: false)
        argv = arguments.is_a?(Array) ? arguments : arguments.split(' ')
        cli  = Warp::Dir::App::CLI.new(argv)
        if yield_before_validation
          yield(cli) if block_given?
        end
        cli.validate
        unless yield_before_validation
          yield(cli) if block_given?
        end
        cli.run
      end

      def output_matches(output, expected)
        if expected.is_a?(Regexp)
          expected.match(output)
        elsif expected.is_a?(String)
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
        STDERR.puts(e.inspect)
        STDERR.puts(e.backtrace.join("\n"))
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

# RSpec::Matchers.define :eval_to_true_after_validate do |expected|
#   match do |actual|
#     expected_type = expected.is_a?(Symbol) ?
#       Warp::Dir::App::Response::RETURN_TYPE[expected_type] :
#       expected
#     response = run_and_yield(expected)
#     response.type == expected_type
#   end
#   failure_message_for_should_not do |actual|
#     "expected #{expected} to produce return type #{}"
#   end
# end
