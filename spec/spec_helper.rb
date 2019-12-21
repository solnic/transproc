# frozen_string_literal: true

if RUBY_ENGINE == 'ruby' && ENV['COVERAGE'] == 'true'
  require 'yaml'
  rubies = YAML.load(File.read(File.join(__dir__, '..', '.travis.yml')))['rvm']
  latest_mri = rubies.select { |v| v =~ /\A\d+\.\d+.\d+\z/ }.max

  if RUBY_VERSION == latest_mri
    require 'simplecov'
    SimpleCov.start do
      add_filter '/spec/'
    end
  end
end

if defined? Warning
  require 'warning'

  Warning.ignore(/rspec/)
  Warning.process { |w| raise RuntimeError, w } unless ENV['NO_WARNING']
end

begin
  require 'byebug'
rescue LoadError;end

require 'transproc/all'

root = Pathname(__FILE__).dirname
Dir[root.join('support/*.rb').to_s].each { |f| require f }
