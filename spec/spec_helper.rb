if RUBY_ENGINE == 'ruby' && RUBY_VERSION == '2.3.1'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'equalizer'
require 'anima'
require 'ostruct'
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
