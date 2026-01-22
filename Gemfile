# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'byebug', '~> 11.1'
gem 'readline' # Required for byebug in Ruby 4.0.

group :development, :test do
  gem 'irb', '~> 1.16'
  gem 'rake', '~> 13.2'
  gem 'rspec', '~> 3.13'
  gem 'rspec-sleeping_king_studios', '~> 2.8', '>= 2.8.3'
  gem 'rubocop', '~> 1.82'
  gem 'rubocop-rake', '~> 0.7'
  gem 'rubocop-rspec', '~> 3.8'
  gem 'simplecov', '~> 0.22'
  gem 'sleeping_king_studios-tasks', '~> 0.4', '>= 0.4.1'
  gem 'thor', '~> 1.4'
end

group :docs do
  gem 'logger', '~> 1.7'

  gem 'jekyll', '~> 4.3'
  gem 'jekyll-theme-dinky', '~> 0.2'

  # Use Kramdown to parse GFM-dialect Markdown.
  gem 'kramdown-parser-gfm', '~> 1.1'

  gem 'sleeping_king_studios-docs', '~> 0.2', '>= 0.2.1'

  # Use Webrick as local content server.
  gem 'webrick', '~> 1.8'

  gem 'yard', '~> 0.9', require: false
end
