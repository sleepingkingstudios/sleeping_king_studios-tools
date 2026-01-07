# frozen_string_literal: true

require_relative 'lib/sleeping_king_studios/tools/version'

Gem::Specification.new do |gem|
  gem.name        = 'sleeping_king_studios-tools'
  gem.version     = SleepingKingStudios::Tools::VERSION
  gem.summary     = 'A library of utility services and concerns.'
  gem.description = <<~DESCRIPTION
    A library of utility services and concerns to expand the functionality of
    core classes without polluting the global namespace.
  DESCRIPTION
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.metadata = {
    'bug_tracker_uri'       => 'https://github.com/sleepingkingstudios/sleeping_king_studios-tools/issues',
    'source_code_uri'       => 'https://github.com/sleepingkingstudios/sleeping_king_studios-tools',
    'rubygems_mfa_required' => 'true'
  }

  gem.required_ruby_version = ['>= 3.2', '< 5']
  gem.require_path          = 'lib'
  gem.files                 = Dir['lib/**/*.rb', 'LICENSE', '*.md']
end
