# lib/sleeping_king_studios/tools/toolbox/configuration.rb

require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  class Configuration
    module ClassMethods
      DEFAULT_OPTION = Object.new.freeze

      # Defines a nested namespace for the configuration object.
      def namespace namespace_name, &block
        namespace =
          (@namespaces ||= {}).fetch(namespace_name) do
            @namespaces[namespace_name] = define_namespace namespace_name
          end # fetch

        namespace.instance_exec namespace, &block if block_given?

        namespace
      end # method namespace

      # Defines an option for the configuration object.
      def option option_name, allow_nil: false, default: DEFAULT_OPTION, enum: nil
        options = {
          :allow_nil => allow_nil,
          :default   => default,
          :enum      => enum
        } # end hash

        define_accessor option_name, options
        define_mutator  option_name, options
      end # class method option

      private

      def define_accessor option_name, options
        define_method option_name do
          __get_value__(option_name, options)
        end # method option_name
      end # method define_accessor

      def define_mutator option_name, options
        writer_name = :"#{option_name}="

        define_method writer_name do |value|
          __set_value__(option_name, value, options)
        end # method option_name=
      end # method define_mutator

      def define_namespace namespace_name
        namespace =
          Class.new(SleepingKingStudios::Tools::Toolbox::Configuration)

        define_method namespace_name do
          if instance_variable_defined?(:"@#{namespace_name}")
            return instance_variable_get(:"@#{namespace_name}")
          end # if

          data   = __get_value__(namespace_name, :default => Object.new)
          config = namespace.new(data)

          config.__root_namespace__ = __root_namespace__ || self

          instance_variable_set(:"@#{namespace_name}", config)

          config
        end # method namespace_name

        namespace
      end # method define_namespace
    end # module
    extend ClassMethods

    DEFAULT_OPTION = ClassMethods::DEFAULT_OPTION

    # @param data [Hash, Object] The data source used to populate configuration
    #   values. Can be a Hash or a data object. If the data source is nil, or no
    #   data source is given, values will be set to their respective defaults.
    def initialize data = nil
      @__data__           = __objectify_data__(data)
      @__root_namespace__ = self

      yield(singleton_class) if block_given?
    end # constructor

    def [] key
      send(key) if respond_to?(key)
    end # method []

    def []= key, value
      send(:"#{key}=", value)
    end # method []=

    def dig *keys
      keys.reduce(self) do |hsh, key|
        value = hsh[key]

        return value if value.nil?

        value
      end # reduce
    end # method dig

    def fetch key, default = DEFAULT_OPTION
      return send(key) if respond_to?(key)

      return default unless default == DEFAULT_OPTION

      return yield if block_given?

      raise KeyError, 'key not found'
    end # method fetch

    protected

    attr_accessor :__root_namespace__

    private

    attr_reader :__data__

    def __blank_value__ value
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end # method __blank_value__

    def __evaluate_default__ default
      default.is_a?(Proc) ? __root_namespace__.instance_exec(&default) : default
    end # method __evaluate_default__

    def __get_value__ name, options
      default_given = options[:default] != DEFAULT_OPTION

      if __data__.respond_to?(name)
        value = __data__.send name

        if value.nil? && default_given
          value = __evaluate_default__(options[:default])
        end # if

        __validate_value__ value, options

        value
      elsif instance_variable_defined?(:"@#{name}")
        # Recall values locally if data source is immutable.
        return instance_variable_get(:"@#{name}")
      elsif default_given
        value = __evaluate_default__(options[:default])

        __validate_value__ value, options

        value
      else
        __validate_value__ nil, options

        nil
      end # if-else
    end # method __get_value__

    def __objectify_data__ data
      return data unless data.is_a?(Hash)

      return Object.new if data.empty?

      obj = Struct.new(*data.keys).new

      data.each do |key, value|
        val = value.is_a?(Hash) ? __objectify_data__(value) : value

        obj.send :"#{key}=", val
      end # each

      obj
    end # method __objectify_data__

    def __set_value__ name, value, options
      writer_name = :"#{name}="

      __validate_value__ value, options

      if __data__.respond_to?(writer_name)
        __data__.send(writer_name, value)
      else
        # Store values locally if data source is immutable.
        instance_variable_set(:"@#{name}", value)
      end # if-else
    end # method __set_value__

    def __validate_value__ value, options
      return if __blank_value__(value) && options[:allow_nil]

      if options[:enum] && !options[:enum].include?(value)
        array_tools   = ::SleepingKingStudios::Tools::ArrayTools
        valid_options =
          array_tools.
            humanize_list(
              options[:enum].map(&:inspect),
              :last_separator => ' or '
            ) # end humanize_list

        raise RuntimeError,
          "expected option to be #{valid_options}, but was #{value.inspect}"
      end # if
    end # method __validate_value__
  end # class
end # module
