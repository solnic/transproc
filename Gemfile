source 'https://rubygems.org'

gemspec

group :test do
  gem 'equalizer'

  gem 'anima'

  platform :mri do
    if RUBY_VERSION >= '2.5'
      gem 'mutant', github: 'mbj/mutant', branch: 'master'
      gem 'mutant-rspec'
    end

    gem 'codeclimate-test-reporter', require: false
    gem 'simplecov', require: false
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
