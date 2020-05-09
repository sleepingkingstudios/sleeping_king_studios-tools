# frozen_string_literal: true

require 'sleeping_king_studios/tools/core_tools'
require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Abstract base class for defining configuration objects.
  class Configuration # rubocop:disable Metrics/ClassLength
    # Class methods for configuration objects.
    module ClassMethods
      DEFAULT_OPTION = Object.new.freeze

      # Defines a nested namespace for the configuration object.
      #
      # A namespace is represented by a nested configuration object, which has
      # its own options and namespaces.
      #
      # @param namespace_name [String] The name of the namespace.
      #
      # @yield namespace If a block is given, that block will be executed in the
      #   context of the newly created namespace.
      #
      # @return [Configuration] the created namespace object.
      def namespace(namespace_name, &block)
        guard_abstract_class!

        namespace =
          (@namespaces ||= {}).fetch(namespace_name) do
            @namespaces[namespace_name] = define_namespace namespace_name
          end

        namespace.instance_exec(namespace, &block) if block_given?

        namespace
      end

      # Defines an option for the configuration object.
      #
      # A configuration option has a name and a value. It can be defined with a
      # default value, or to allow or prohibit nil values or restrict possible
      # values to a given set.
      #
      # @param option_name [String] The name of the option.
      # @param allow_nil [true, false] If false, setting the option value to nil
      #   or an empty value will raise an error, as will trying to access the
      #   value when it has not been set. Defaults to false.
      # @param default [Object] The default value for the option. If this is not
      #   set, the default value for the option will be nil.
      # @param enum [Array] An enumerable list of valid values for the option.
      def option(
        option_name,
        allow_nil: false,
        default:   DEFAULT_OPTION,
        enum:      nil
      )
        guard_abstract_class!

        options = {
          allow_nil: allow_nil,
          default:   default,
          enum:      enum
        }

        define_option_accessor option_name, options
        define_option_mutator  option_name, options

        option_name.intern
      end

      private

      def define_namespace(namespace_name)
        namespace =
          Class.new(SleepingKingStudios::Tools::Toolbox::Configuration)

        define_namespace_accessor(namespace_name, namespace)

        namespace
      end

      def define_namespace_accessor(namespace_name, namespace_class)
        namespace_ivar = :"@#{namespace_name}"

        define_method namespace_name do |&block|
          if instance_variable_defined?(namespace_ivar)
            return instance_variable_get(namespace_ivar).tap do |config|
              block&.call(config)
            end
          end

          initialize_namespace(namespace_name, namespace_class, &block)
        end
      end

      def define_option_accessor(option_name, options)
        define_method option_name do
          get_value(option_name, options)
        end
      end

      def define_option_mutator(option_name, options)
        writer_name = :"#{option_name}="

        define_method writer_name do |value|
          set_value(option_name, value, options)
        end
      end

      def guard_abstract_class!
        return unless self == SleepingKingStudios::Tools::Toolbox::Configuration

        raise "can't define namespace or option on abstract class"
      end
    end
    extend ClassMethods

    DEFAULT_OPTION = ClassMethods::DEFAULT_OPTION

    # @param data [Hash, Object] The data source used to populate configuration
    #   values. Can be a Hash or a data object. If the data source is nil, or no
    #   data source is given, values will be set to their respective defaults.
    #
    # @yieldparam [Class] The singleton class of the new configuration object.
    def initialize(data = nil)
      @data           = convert_data_to_struct(data)
      @root_namespace = self

      return unless block_given?

      SleepingKingStudios::Tools::CoreTools
        .deprecate('Configuration#initialize with a block')

      yield(singleton_class)
    end

    def [](key)
      send(key) if respond_to?(key)
    end

    def []=(key, value)
      send(:"#{key}=", value) if respond_to?(key)
    end

    def dig(*keys)
      keys.reduce(self) do |config, key|
        value = config[key]

        return value if value.nil?

        value
      end
    end

    def fetch(key, default = DEFAULT_OPTION)
      return send(key) if respond_to?(key)

      return default unless default == DEFAULT_OPTION

      return yield(key) if block_given?

      raise KeyError, "key not found: #{key.inspect}"
    end

    protected

    attr_accessor :root_namespace

    private

    attr_reader :data

    def blank_value?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end

    def convert_data_to_struct(data)
      return data unless data.is_a?(Hash)

      return Object.new if data.empty?

      obj = Struct.new(*data.keys).new

      data.each do |key, value|
        val = value.is_a?(Hash) ? convert_data_to_struct(value) : value

        obj.send :"#{key}=", val
      end

      obj
    end

    def evaluate_default(default)
      return default unless default.is_a?(Proc)

      root_namespace.instance_exec(&default)
    end

    def get_default_value(options)
      value = evaluate_default(options[:default])

      validate_value value, options

      value
    end

    def get_method_value(name, options)
      value = data.send(name)

      if value.nil? && options[:default] != DEFAULT_OPTION
        value = evaluate_default(options[:default])
      end

      validate_value(value, options)

      value
    end

    def get_value(name, options)
      if data.respond_to?(name)
        get_method_value(name, options)
      elsif instance_variable_defined?(:"@#{name}")
        instance_variable_get(:"@#{name}")
      elsif options[:default] != DEFAULT_OPTION
        get_default_value(options)
      else
        validate_value(nil, options)

        nil
      end
    end

    def initialize_namespace(namespace_name, namespace_class, &block)
      data   = get_value(namespace_name, default: Object.new)
      config = namespace_class.new(data)

      config.root_namespace = root_namespace || self

      instance_variable_set(:"@#{namespace_name}", config)

      block.call(config) if block_given?

      config
    end

    def invalid_value_message(value, options)
      array_tools   = ::SleepingKingStudios::Tools::ArrayTools
      valid_options =
        array_tools
        .humanize_list(
          options[:enum].map(&:inspect),
          last_separator: ' or '
        )

      "expected option to be #{valid_options}, but was #{value.inspect}"
    end

    def set_value(name, value, options)
      writer_name = :"#{name}="

      validate_value value, options

      if data.respond_to?(writer_name)
        data.send(writer_name, value)
      else
        # Store values locally if data source is immutable.
        instance_variable_set(:"@#{name}", value)
      end
    end

    def validate_value(value, options)
      return if blank_value?(value) && options[:allow_nil]

      return unless options[:enum] && !options[:enum].include?(value)

      raise invalid_value_message(value, options)
    end
  end
end
