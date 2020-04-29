# frozen_string_literal: true

module Hyrax
  ##
  # @api private
  #
  # This is a simple yaml config-driven schema loader
  #
  # @see config/metadata/basic_metadata.yaml for an example configuration
  class SimpleSchemaLoader
    ##
    # @param [Symbol] schema
    #
    # @return [Hash<Symbol, Dry::Types::Type>] a map from attribute names to
    #   types
    def attributes_for(schema:)
      definitions(schema).each_with_object({}) do |definition, hash|
        hash[definition.name] = definition.type
      end
    end

    ##
    # @param [Symbol] schema
    #
    # @return [Hash<Symbol, Symbol>] a map from index keys to attribute names
    def index_rules_for(schema:)
      definitions(schema).each_with_object({}) do |definition, hash|
        definition.index_keys.each do |key|
          hash[key] = definition.name
        end
      end
    end

    ##
    # @api private
    class AttributeDefinition
      ##
      # @!attr_reader :config
      #   @return [Hash<String, Object>]
      # @!attr_reader :name
      #   @return [#to_sym]
      attr_reader :config, :name

      ##
      # @param [#to_sym] name
      # @param [Hash<String, Object>] config
      def initialize(name, config)
        @config = config
        @name   = name.to_sym
      end

      ##
      # @return [Enumerable<Symbol>]
      def index_keys
        config.fetch('index_keys', []).map(&:to_sym)
      end

      ##
      # @return [Dry::Types::Type]
      def type
        collection_type = config['multiple'] ? Valkyrie::Types::Array : Identity
        collection_type.of(type_for(config['type']))
      end

      ##
      # @api private
      #
      # This class acts as a Valkyrie/Dry::Types collection with typed members,
      # but instead of wrapping the given type with itself as the collection type
      # (as in `Valkyrie::Types::Array.of(MyType)`), it returns the given type.
      #
      # @example
      #   Identity.of(Valkyrie::Types::String) # => Valkyrie::Types::String
      #
      class Identity
        ##
        # @param [Dry::Types::Type]
        # @return [Dry::Types::Type] the type passed in
        def self.of(type)
          type
        end
      end

      private

        ##
        # Maps a configuration string value to a `Valkyrie::Type`.
        #
        # @param [String]
        # @return [Dry::Types::Type]
        def type_for(type)
          case type
          when 'uri'
            Valkyrie::Types::URI
          when 'date_time'
            Valkyrie::Types::DateTime
          else
            "Valkyrie::Types::#{type.capitalize}".constantize
          end
        end
    end

    class UndefinedSchemaError < ArgumentError; end

    private

      ##
      # @param [#to_s] schema_name
      # @return [Enumerable<AttributeDefinition]
      def definitions(schema_name)
        schema_config(schema_name)['attributes'].map do |name, config|
          AttributeDefinition.new(name, config)
        end
      end

      ##
      # @param [#to_s] schema_name
      # @return [Hash]
      def schema_config(schema_name)
        raise(UndefinedSchemaError, "No schema defined: #{schema_name}") unless
          File.exist?(config_path(schema_name))

        YAML.safe_load(File.open(config_path(schema_name)))
      end

      def config_path(schema_name)
        Hyrax::Engine.root.to_s + "/config/metadata/#{schema_name}.yaml"
      end
  end
end
