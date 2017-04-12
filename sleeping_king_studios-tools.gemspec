# sleeping_king_studios-tools.gemspec

$: << './lib'
require 'sleeping_king_studios/tools/version'

Gem::Specification.new do |gem|
  gem.name        = 'sleeping_king_studios-tools'
  gem.version     = SleepingKingStudios::Tools::VERSION
  gem.date        = Time.now.utc.strftime "%Y-%m-%d"
  gem.summary     = 'A library of utility services and concerns.'
  gem.description = <<-DESCRIPTION
A library of utility services and concerns to expand the functionality of core
classes without polluting the global namespace.
  DESCRIPTION
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.require_path = 'lib'
  gem.files        = Dir["lib/**/*.rb", "LICENSE", "*.md"]

  gem.add_development_dependency 'rake',   '~> 12.0'
  gem.add_development_dependency 'rspec',  '~> 3.4'
  gem.add_development_dependency 'byebug', '~> 8.2',  '>= 8.2.2'

  gem.add_development_dependency 'rspec-sleeping_king_studios', '~> 2.1', '>= 2.1.1'
end # gemspec
