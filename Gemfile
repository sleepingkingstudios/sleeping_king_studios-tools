# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'byebug', '~> 11.1'

group :development, :test do
  gem 'rake', '~> 13.2'
  gem 'rspec', '~> 3.13'
  gem 'rspec-sleeping_king_studios', '~> 2.7'
  gem 'rubocop', '~> 1.73'
  gem 'rubocop-rake', '~> 0.6'
  gem 'rubocop-rspec', '~> 3.5'
  gem 'simplecov', '~> 0.22'
  gem 'sleeping_king_studios-tasks', '~> 0.4', '>= 0.4.1'
  gem 'thor', '~> 1.3'
end

group :docs do
  gem 'jekyll', '~> 4.3'
  gem 'jekyll-theme-dinky', '~> 0.2'

  # Use Kramdown to parse GFM-dialect Markdown.
  gem 'kramdown-parser-gfm', '~> 1.1'

  gem 'sleeping_king_studios-docs',
    git:    'https://github.com/sleepingkingstudios/sleeping_king_studios-docs.git',
    branch: 'main'

  # Use Webrick as local content server.
  gem 'webrick', '~> 1.8'

  gem 'yard', '~> 0.9', require: false
end
