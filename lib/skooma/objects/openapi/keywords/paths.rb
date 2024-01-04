# frozen_string_literal: true

module Skooma
  module Objects
    class OpenAPI
      module Keywords
        class Paths < JSONSkooma::Keywords::Base
          self.key = "paths"
          self.value_schema = :object_of_schemas
          self.schema_value_class = Objects::PathItem

          ROUTE_REGEXP = /\{([^}]+)}/.freeze

          def initialize(parent_schema, value)
            super
            @regexp_map = json.filter_map do |path, subschema|
              next unless path.include?("{") && path.include?("}")

              path_regex = path.gsub(ROUTE_REGEXP, "(?<\\1>[^/?#]+)")
              path_regex = Regexp.new("\\A#{path_regex}\\z")

              [path, path_regex, subschema]
            end
          end

          def evaluate(instance, result)
            path, attributes, path_schema = find_route(instance["path"])

            return result.failure("Path #{instance["path"]} not found in schema") unless path

            result.call(instance, path) do |subresult|
              subresult.annotate({"path_attributes" => attributes})
              path_schema.evaluate(instance, subresult)

              if subresult.passed? && subresult.children.any?
                result.success
              else
                result.failure("Path #{instance["path"]} is invalid")
              end
            end
          end

          private

          def find_route(instance_path)
            instance_path = instance_path.delete_prefix(json.root.path_prefix)
            return [instance_path, {}, json[instance_path]] if json.key?(instance_path)

            @regexp_map.reduce(nil) do |result, (path, path_regex, subschema)|
              next result unless path.include?("{") && path.include?("}")

              match = instance_path.match(path_regex)
              next result if match.nil?
              next result if result && result[1].length <= match.named_captures.length

              [path, match.named_captures, subschema]
            end
          end
        end
      end
    end
  end
end
