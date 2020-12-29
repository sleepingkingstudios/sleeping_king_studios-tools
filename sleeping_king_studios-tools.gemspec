# frozen_string_literal: true

$LOAD_PATH << './lib'

require 'sleeping_king_studios/tools/version'

Gem::Specification.new do |gem|
  gem.name        = 'sleeping_king_studios-tools'
  gem.version     = SleepingKingStudios::Tools::VERSION
  gem.date        = Time.now.utc.strftime '%Y-%m-%d'
  gem.summary     = 'A library of utility services and concerns.'
  gem.description = <<~DESCRIPTION
    A library of utility services and concerns to expand the functionality of
    core classes without polluting the global namespace.
  DESCRIPTION
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.required_ruby_version = '>= 2.5.0'
  gem.require_path          = 'lib'
  gem.files                 = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.add_development_dependency 'byebug',        '~> 11.1'
  gem.add_development_dependency 'rake',          '~> 13.0'
  gem.add_development_dependency 'rspec',         '~> 3.10'
  gem.add_development_dependency 'rubocop',       '~> 1.6'
  gem.add_development_dependency 'rubocop-rake',  '~> 0.5'
  gem.add_development_dependency 'rubocop-rspec', '~> 2.1'
  gem.add_development_dependency 'simplecov',     '~> 0.18.5'
  gem.add_development_dependency 'thor',          '~> 1.0'

  gem.add_development_dependency 'rspec-sleeping_king_studios', '~> 2.5'
  gem.add_development_dependency 'sleeping_king_studios-tasks', '~> 0.3'
end
