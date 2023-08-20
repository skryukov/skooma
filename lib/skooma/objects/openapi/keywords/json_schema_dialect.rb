# frozen_string_literal: true

module Skooma
  module Objects
    class OpenAPI
      module Keywords
        class JSONSchemaDialect < JSONSkooma::Keywords::Base
          self.key = "jsonSchemaDialect"
          self.static = true

          def initialize(parent_schema, value)
            super

            uri = URI.parse(value)
            parent_schema.json_schema_dialect_uri = uri
          end
        end
      end
    end
  end
end
