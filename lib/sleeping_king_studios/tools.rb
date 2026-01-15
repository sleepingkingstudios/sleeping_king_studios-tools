# frozen_string_literal: true

# Hic iacet Arthurus, rex quondam, rexque futurus.
module SleepingKingStudios
  # A library of utility services and concerns to expand the functionality of
  # core classes without polluting the global namespace.
  module Tools
    autoload :Base,         'sleeping_king_studios/tools/base'
    autoload :ArrayTools,   'sleeping_king_studios/tools/array_tools'
    autoload :Assertions,   'sleeping_king_studios/tools/assertions'
    autoload :CoreTools,    'sleeping_king_studios/tools/core_tools'
    autoload :HashTools,    'sleeping_king_studios/tools/hash_tools'
    autoload :IntegerTools, 'sleeping_king_studios/tools/integer_tools'
    autoload :Messages,     'sleeping_king_studios/tools/messages'
    autoload :ObjectTools,  'sleeping_king_studios/tools/object_tools'
    autoload :StringTools,  'sleeping_king_studios/tools/string_tools'
    autoload :Toolbelt,     'sleeping_king_studios/tools/toolbelt'
    autoload :Toolbox,      'sleeping_king_studios/tools/toolbox'
    autoload :Undefined,    'sleeping_king_studios/tools/undefined'
    autoload :Version,      'sleeping_king_studios/tools/version'

    UNDEFINED = Undefined.new
    Object.instance_method(:freeze).bind(UNDEFINED).call

    @initializer = SleepingKingStudios::Tools::Toolbox::Initializer.new do
      SleepingKingStudios::Tools::Messages::Registry
        .global
        .register(
          scope:    'sleeping_king_studios.tools.assertions',
          strategy: Assertions::MessagesStrategy.new
        )
    end

    # @return [String] the absolute path to the gem directory.
    def self.gem_path
      sep     = File::SEPARATOR
      pattern = /#{sep}lib#{sep}sleeping_king_studios#{sep}?\z/

      __dir__.sub(pattern, '')
    end

    # Sets configuration for the module and its dependencies.
    def self.initialize
      @initializer.call
    end

    # @return [String] the current version of the gem.
    def self.version
      @version ||= Version.to_gem_version
    end
  end
end
