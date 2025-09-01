# frozen_string_literal: true

module Skooma
  module Objects
    # Holds a set of reusable objects for different aspects of the OAS.
    # https://spec.openapis.org/oas/v3.1.0#components-object
    class Components < JSONSkooma::JSONNode
      CLASSES_MAP = {
        "schemas" => JSONSkooma::JSONSchema,
        "responses" => Response,
        "parameters" => Parameter,
        "examples" => JSONSkooma::JSONNode,
        "requestBodies" => RequestBody,
        "headers" => Header,
        "securitySchemes" => JSONSkooma::JSONNode,
        "links" => JSONSkooma::JSONNode,
        "callbacks" => JSONSkooma::JSONNode,
        "pathItems" => PathItem
      }

      def map_object_value(value)
        value.map do |k, v|
          key = k.to_s
          value = JSONSkooma::JSONNode.new(v, key: key, parent: self, item_class: CLASSES_MAP.fetch(key), **@item_params, metaschema_uri: parent.json_schema_dialect_uri)
          [key, value]
        end.to_h
      end
    end
  end
end
