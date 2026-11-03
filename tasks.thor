# frozen_string_literal: true

require 'cuprum/cli'

Cuprum::Cli.initializer.call

require 'cuprum/cli/integrations/thor/registry'

registry = Cuprum::Cli::Integrations::Thor::Registry.new

require 'sleeping_king_studios/docs/jekyll'

# CI Commands
registry.register Cuprum::Cli::Commands::Ci::RSpecCommand
registry.register Cuprum::Cli::Commands::Ci::RSpecEachCommand

# File Commands
registry.register Cuprum::Cli::Commands::File::NewCommand

# Docs Commands
registry.register SleepingKingStudios::Docs::Jekyll.install_commands
registry.register SleepingKingStudios::Docs::Jekyll.commands
