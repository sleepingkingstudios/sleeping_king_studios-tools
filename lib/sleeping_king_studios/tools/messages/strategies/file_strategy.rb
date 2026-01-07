# frozen_string_literal: true

require 'sleeping_king_studios/tools/messages/strategies'
require 'sleeping_king_studios/tools/messages/strategies/hash_strategy'

module SleepingKingStudios::Tools::Messages::Strategies
  # Messaging strategy that loads message templates from the given file.
  class FileStrategy < HashStrategy
    # Exception raised when reading the templates file.
    class FileError < StandardError; end

    # @param file_name [String] the full path to the file with the templates
    #   data.
    def initialize(file_name)
      validate_file_name(file_name)

      @file_name = file_name
      raw_data   = read_file(file_name)
      templates  = parse_templates(raw_data)

      super(templates)
    end

    # @return [String] the full path to the file with the templates data.
    attr_reader :file_name

    private

    def parse_json_templates(raw_data)
      require 'json'

      JSON.parse(raw_data)
    rescue JSON::ParserError => exception
      raise ParseError, "unable to parse templates file - #{exception.message}"
    end

    def parse_templates(raw_data)
      case File.extname(file_name)
      when '.json'
        return parse_json_templates(raw_data)
      when '.yaml', '.yml'
        return parse_yaml_templates(raw_data)
      end

      raise FileError,
        'unable to read templates file - unrecognized extension ' \
        "#{File.extname(file_name).inspect}"
    end

    def parse_yaml_templates(raw_data)
      require 'yaml'

      YAML.safe_load(raw_data) || {}
    rescue Psych::SyntaxError => exception
      raise ParseError, "unable to parse templates file - #{exception.message}"
    end

    def read_file(file_name)
      unless File.file?(file_name)
        raise FileError, "templates file does not exist at #{file_name}"
      end

      begin
        File.read(file_name)
      rescue StandardError => exception
        raise FileError,
          "unable to read templates file at #{file_name} - #{exception.message}"
      end
    end

    def validate_file_name(file_name)
      raise ArgumentError, "file name can't be blank" if file_name.nil?

      unless file_name.is_a?(String) || file_name.is_a?(Pathname)
        raise ArgumentError, 'file name is not an instance of String'
      end

      raise ArgumentError, "file name can't be blank" if file_name.to_s.empty?
    end
  end
end
