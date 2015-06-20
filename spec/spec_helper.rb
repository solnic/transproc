if RUBY_ENGINE == 'rbx'
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'equalizer'
require 'anima'
require 'transproc/all'

begin
  require 'byebug'
rescue LoadError
end

root = Pathname(__FILE__).dirname
Dir[root.join('support/*.rb').to_s].each { |f| require f }

RSpec.configure do |config|
  config.include(Transproc::Helper)
end
