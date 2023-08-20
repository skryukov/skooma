# frozen_string_literal: true

module Skooma
  module Keywords
    module OAS31
      class Schema < JSONSkooma::Keywords::Base
        self.key = "schema"

        def evaluate(instance, result)
          json.evaluate(instance.coerce(json), result)
        end

        def each_schema
          yield json
        end

        private

        def wrap_value(value)
          JSONSkooma::JSONSchema.new(
            value,
            key: key,
            parent: parent_schema,
            registry: parent_schema.registry,
            cache_id: parent_schema.cache_id,
            metaschema_uri: parent_schema.json_schema_dialect_uri
          )
        end
      end
    end
  end
end
