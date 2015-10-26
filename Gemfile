source 'https://rubygems.org'

gemspec

group :test do
  gem 'equalizer'
  gem 'codeclimate-test-reporter', require: nil

  if RUBY_VERSION >= '2.1'
    gem 'anima'
    platform :mri do
      gem 'mutant', github: 'mbj/mutant', branch: 'master'
      gem 'mutant-rspec'
    end
  else
    gem 'anima', '~> 0.2.0'
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
