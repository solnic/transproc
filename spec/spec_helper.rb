if RUBY_ENGINE == 'rbx'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'transproc/all'

begin
  require 'byebug'
rescue LoadError
end

RSpec.configure do |config|
  config.include(Transproc::Helper)
end
