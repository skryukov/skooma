# frozen_string_literal: true

module Skooma
  module Objects
    class Base < JSONSkooma::JSONSchema
      DEFAULT_OPTIONS = {
        registry: REGISTRY_NAME
      }.freeze

      def initialize(value, **options)
        super(value, **DEFAULT_OPTIONS.merge(options))
      end

      def bootstrap(value)
        # nothing to do
      end

      def kw_classes
        []
      end

      def json_schema_dialect_uri
        root.json_schema_dialect_uri
      end

      private

      def kw_class(k)
        kw_classes.find { |kw| kw.key == k } || JSONSkooma::Keywords::Unknown[k]
      end
    end
  end
end
