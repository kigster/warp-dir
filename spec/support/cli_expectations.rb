require 'rspec/expectations'
require 'warp/dir/app/cli'

require 'rspec/expectations'

def run_command!(arguments)
  argv = arguments.is_a?(Array) ? arguments : arguments.split(' ')
  cli  = Warp::Dir::App::CLI.new(argv)
  cli.validate
  if block_given?
    cli.valid ? yield(cli) : nil
  else
    cli.run
  end
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

RSpec::Matchers.define :output do |*expectations|
  match do |actual|
    expectations.all? do |expected|
      response = run_command!(actual)
      response.messages.any? { |m| output_matches(m, expected) }
    end
  end
  match_when_negated do |actual|
    expectations.none? do |expected|
      response = run_command!(actual)
      response.messages.any? { |m| output_matches(m, expected) }
    end
  end
end

RSpec::Matchers.define :validate do |expected|
  match do |actual|
    expected = expected || block_arg
    if expected.is_a?(Proc)
      run_command!(actual) do |cli|
        expected.call(cli)
      end
    else
      raise TypeError.new('Expected must be a block')
    end
  end
end

RSpec::Matchers.define :exit_with do |expected|
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
