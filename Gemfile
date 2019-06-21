source 'https://rubygems.org'

gemspec

group :test do
  gem 'rspec', '~> 3.8'
  gem 'dry-equalizer', '~> 0.2'

  platform :mri do
    gem 'simplecov', require: false
  end
end

group :tools do
  gem 'byebug', platform: :mri
  gem 'benchmark-ips'
end
