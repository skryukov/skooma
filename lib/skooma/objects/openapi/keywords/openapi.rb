# frozen_string_literal: true

module Skooma
  module Objects
    class OpenAPI
      module Keywords
        class OpenAPI < JSONSkooma::Keywords::BaseAnnotation
          self.key = "openapi"

          MAPPING = {
            "3.1.0" => "https://spec.openapis.org/oas/3.1/schema-base/2022-10-07",
            "3.1.1" => "https://spec.openapis.org/oas/3.1/schema-base/2025-02-13",
            "3.1.2" => "https://spec.openapis.org/oas/3.1/schema-base/2025-09-15",
            "3.2.0" => "https://spec.openapis.org/oas/3.1/schema-base/2025-09-17"
          }

          LATEST = "3.2.0"

          def initialize(parent_schema, value)
            unless value.to_s.start_with? "3.1."
              raise Error, "Only OpenAPI version 3.1.x is supported, got #{value}"
            end

            parent_schema.metaschema_uri = MAPPING[value.to_s] || MAPPING[LATEST]

            parent_schema.json_schema_dialect_uri = "https://spec.openapis.org/oas/3.1/dialect/base"

            super
          end
        end
      end
    end
  end
end
