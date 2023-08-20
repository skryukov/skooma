# frozen_string_literal: true

module Skooma
  module Objects
    class OpenAPI
      module Keywords
        class OpenAPI < JSONSkooma::Keywords::BaseAnnotation
          self.key = "openapi"

          def initialize(parent_schema, value)
            unless value.to_s.start_with? "3.1."
              raise Error, "Only OpenAPI version 3.1.x is supported, got #{value}"
            end

            parent_schema.metaschema_uri = "https://spec.openapis.org/oas/3.1/schema-base/2022-10-07"
            parent_schema.json_schema_dialect_uri = "https://spec.openapis.org/oas/3.1/dialect/base"

            super
          end
        end
      end
    end
  end
end
