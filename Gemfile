source 'https://rubygems.org'

gemspec

group :test do
  gem 'equalizer'
  gem 'anima'
  gem 'mutant', "< 0.7.9" if RUBY_VERSION < "2.1"
  gem 'mutant', "~> 0.7"  if RUBY_VERSION >= "2.1"
  gem 'mutant-rspec'
  gem 'codeclimate-test-reporter', require: nil
end

group :tools do
  gem 'rubocop', '~> 0.30.0'
  gem 'byebug', platform: :mri
  gem 'benchmark-ips'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
end
