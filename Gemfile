source 'https://rubygems.org'

gemspec

group :test do
  gem 'equalizer'

  if RUBY_VERSION >= '2.1'
    gem 'anima'
    platform :mri do
      gem 'mutant', github: 'mbj/mutant', branch: 'master'
      gem 'mutant-rspec'

      gem 'codeclimate-test-reporter', require: false
      gem 'simplecov', require: false
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
  gem 'hotch'
end
