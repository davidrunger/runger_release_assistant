# frozen_string_literal: true

ruby file: '.ruby-version'

source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'bundler', require: false
  gem 'pry'
  # Go back to upstream if/when https://github.com/deivid-rodriguez/pry-byebug/pull/ 428 is merged.
  gem 'pry-byebug', github: 'davidrunger/pry-byebug'
  gem 'rake', require: false
  gem 'rspec', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
  gem 'runger_style', require: false
end
