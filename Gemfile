source 'https://rubygems.org'

gemspec

group :test do
  gem 'equalizer'
  gem 'anima'
  gem 'codeclimate-test-reporter', require: nil

  platform :mri do
    gem 'mutant', github: 'mbj/mutant', branch: 'master'
    gem 'mutant-rspec'
  end
end

group :tools do
  gem 'rubocop', '~> 0.30.0'
  gem 'byebug', platform: :mri
  gem 'benchmark-ips'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
end
