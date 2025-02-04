# frozen_string_literal: true

module Skooma
  module Objects
    # OpenAPI Object – the root object of the OpenAPI document.
    # https://spec.openapis.org/oas/v3.1.0#openapi-object
    class OpenAPI < Base
      attr_writer :json_schema_dialect_uri

      def kw_classes
        [
          Keywords::Info,
          Keywords::JSONSchemaDialect,
          Keywords::Paths,
          Keywords::Webhooks,
          Keywords::Components,
          Base::Keywords::Servers,
          Base::Keywords::Security,
          Base::Keywords::Tags,
          Skooma::Keywords::OAS31::Dialect::ExternalDocs
        ]
      end

      def bootstrap(value)
        # always evaluate openapi to check version,
        # and set metaschema_uri and json_schema_dialect_uri
        add_keyword(Keywords::OpenAPI.new(self, value["openapi"]))
      end

      def evaluate(instance, result = nil)
        super(Instance.new(instance), result)
      end

      def path_prefix=(value)
        raise ArgumentError, "Path prefix must be a string" unless value.is_a?(String)

        @path_prefix = value
        @path_prefix = "/#{@path_prefix}" unless @path_prefix.start_with?("/")
        @path_prefix = @path_prefix.delete_suffix("/") if @path_prefix.end_with?("/")
      end

      def enforce_access_modes=(value)
        raise ArgumentError, "Enforce access modes must be a boolean" unless [true, false].include?(value)

        @enforce_access_modes = value
      end

      def enforce_access_modes?
        @enforce_access_modes
      end

      def use_patterns_for_path_matching=(value)
        raise ArgumentError, "Use patterns for path matching must be a boolean" unless [true, false].include?(value)

        @use_patterns_for_path_matching = value
      end

      def use_patterns_for_path_matching?
        @use_patterns_for_path_matching
      end

      def path_prefix
        @path_prefix || ""
      end

      def json_schema_dialect_uri
        @json_schema_dialect_uri || parent_schema&.json_schema_dialect_uri
      end
    end
  end
end
