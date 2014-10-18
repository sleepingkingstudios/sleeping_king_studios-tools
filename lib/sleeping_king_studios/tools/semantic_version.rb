# lib/sleeping_king_studios/tools/semantic_version.rb

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  module SemanticVersion
    FETCH_DEFAULT = Object.new.freeze

    class MissingVersionError < StandardError; end

    def to_gem_version
      str = "#{const_fetch :MAJOR}.#{const_fetch :MINOR}.#{const_fetch :PATCH}"

      prerelease = const_fetch(:PRERELEASE, nil)
      str << ".#{prerelease}" unless prerelease.nil? || prerelease.empty?

      build = const_fetch(:BUILD, nil)
      str << ".#{build}" unless build.nil? || build.empty?

      str
    end # method to_version

    def to_version
      str = "#{const_fetch :MAJOR}.#{const_fetch :MINOR}.#{const_fetch :PATCH}"

      prerelease = const_fetch(:PRERELEASE, nil)
      str << "-#{prerelease}" unless prerelease.nil? || prerelease.empty?

      build = const_fetch(:BUILD, nil)
      str << "+#{build}" unless build.nil? || build.empty?

      str
    end # method to_version

    private

    def const_fetch name, default = FETCH_DEFAULT
      if self.const_defined?(name)
        return self.const_get(name).to_s
      elsif default == FETCH_DEFAULT
        raise MissingVersionError.new "undefined constant for #{name.downcase} version"
      end # if-else
    end # method const_fetch
  end # module
end # module
