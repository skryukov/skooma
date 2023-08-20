# frozen_string_literal: true

module Skooma
  module Keywords
    module OAS31
      module SchemaValue
        def wrap_value(value)
          return super unless value.is_a?(Hash) || value.is_a?(TrueClass) || value.is_a?(FalseClass)

          Objects::OpenAPI.new(value, registry: parent_schema.registry, parent: parent_schema, key: key)
        end

        def each_schema
          return super unless json.is_a?(Objects::OpenAPI)

          yield json
        end
      end
      JSONSkooma::Keywords::ValueSchemas.register_value_schema(:openapi_schema, SchemaValue)
    end
  end
end
