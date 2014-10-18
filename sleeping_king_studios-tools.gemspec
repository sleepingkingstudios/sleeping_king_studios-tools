# sleeping_king_studios-tools.gemspec

require File.expand_path "lib/sleeping_king_studios/tools/version"

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

  gem.add_development_dependency 'pry',   '~> 0.10', '>= 0.10.1'
  gem.add_development_dependency 'rspec', '~> 3.1',  '>= 3.1.0'
end # gemspec
