# frozen_string_literal: true

require "cgi"

module Skooma
  module Objects
    class Parameter
      module Keywords
        module ValueParser
          # https://spec.openapis.org/oas/v3.1.0#style-values
          ARRAY_STYLE_DELIMITERS = {
            "form" => ",",
            "spaceDelimited" => " ",
            "pipeDelimited" => "|"
          }.freeze

          class << self
            def call(instance, result, array: false)
              type = result.sibling(instance, "in")&.annotation
              raise Error, "Missing `in` key #{result.path}" unless type

              key = result.sibling(instance, "name")&.annotation
              raise Error, "Missing `name` key #{result.path}" unless key

              case type
              when "query"
                query_param_value(instance, result, key, array: array)
              when "header"
                instance["headers"][key]
              when "path"
                path_item_result = result.parent
                path_item_result = path_item_result.parent until path_item_result.key.start_with?("/")

                Instance::Attribute.new(
                  path_item_result.annotation["path_attributes"][key],
                  key: "path",
                  parent: instance["path"]
                )
              when "cookie"
                # instance["headers"]["Cookie"]
              else
                raise Error, "Unknown location: #{type}"
              end
            end

            def array_param?(parameter)
              schema = parameter["schema"]
              schema.is_a?(JSONSkooma::JSONSchema) && schema.type == "object" && schema["type"] == "array"
            end

            private

            def query_param_value(instance, result, key, array:)
              params = parse_query(instance["query"]&.value)
              values = params[key]
              # Support the non-standard Rails/Rack/PHP bracket convention
              # (`ids[]=1&ids[]=2`) for array params declared as `name: ids`.
              values = params["#{key}[]"] if values.nil? && array
              return nil if values.nil?

              value =
                if array && !values.last.nil?
                  deserialize_array(values, instance, result)
                else
                  # the last value wins for scalars and value-less keys (e.g. `?ids`)
                  values.last
                end

              Instance::Attribute.new(value, key: key, parent: instance["query"])
            end

            def parse_query(query_string)
              params = {}
              query_string.to_s.split(/[&;]/).each do |pair|
                key, value = pair.split("=", 2).collect { |v| CGI.unescape(v) }
                next unless key

                (params[key] ||= []) << value
              end

              params
            end

            def deserialize_array(values, instance, result)
              style = result.sibling(instance, "style")&.annotation || "form"
              explode = result.sibling(instance, "explode")&.annotation
              explode = style == "form" if explode.nil?

              # exploded arrays are serialized as repeated keys (`ids=1&ids=2`)
              return values.compact if explode

              values.last.split(ARRAY_STYLE_DELIMITERS.fetch(style, ","))
            end
          end
        end
      end
    end
  end
end
