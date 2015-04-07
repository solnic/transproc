if RUBY_ENGINE == "rbx"
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'transproc/all'

begin
  require 'byebug'
rescue LoadError
end

module TransprocHelper
  def t(*args, &block)
    Transproc(*args, &block)
  end
end

RSpec.configure do |config|
  config.include(TransprocHelper)
end
