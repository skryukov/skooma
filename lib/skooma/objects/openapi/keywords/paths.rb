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
          end

          def evaluate(instance, result)
            path, attributes, path_schema = find_route(instance["path"])

            return result.failure("Path #{instance["path"]} not found in schema") unless path

            result.annotate({"current_path" => path})

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

          def regexp_map
            @regexp_map ||= json.filter_map do |path, subschema|
              next unless path.include?("{") && path.include?("}")

              if json.root.use_patterns_for_path_matching?
                pattern_hash = create_hash_of_patterns(subschema)
              else
                pattern_hash = {}
              end

              path_regex = path.gsub(ROUTE_REGEXP) do |match|
                param = match[1..-2]
                if pattern_hash.key?(param)
                  "(?<#{param}>#{pattern_hash[param]})"
                else
                  "(?<#{param}>[^/?#]+)"
                end
              end
              path_regex = Regexp.new("\\A#{path_regex}\\z")

              [path, path_regex, subschema]
            end
          end

          def find_route(instance_path)
            instance_path = instance_path.delete_prefix(json.root.path_prefix)
            return [instance_path, {}, json[instance_path]] if json.key?(instance_path)
            regexp_map.reduce(nil) do |result, (path, path_regex, subschema)|
              next result unless path.include?("{") && path.include?("}")

              match = instance_path.match(path_regex)
              next result if match.nil?
              next result if result && result[1].length <= match.named_captures.length

              [path, match.named_captures, subschema]
            end
          end

          def get_child(parent, child_name)
            if parent
              if parent.key?("$ref")
                parent_to_use = parent.resolve_ref(parent["$ref"])
              else
                parent_to_use = parent
              end
              if parent_to_use.key?(child_name)
                parent_to_use[child_name]
              end
            end
          end

          def create_hash_of_patterns(subschema)
            output = {}
            parameters = []
            parameters = parameters.concat(subschema["parameters"]) if subschema["parameters"]
            for method in %w[get post put patch delete] do
              parameters = parameters.concat(subschema[method]["parameters"]) if subschema[method] && subschema[method]["parameters"]
            end
            for parameter in parameters do
              if get_child(parameter, "in") == "path"
                pattern = "[^/?#]+"
                new_pattern = get_child(parameter, "pattern")
                pattern = new_pattern if new_pattern
                new_pattern = get_child(get_child(parameter, "schema"), "pattern")
                pattern = new_pattern if new_pattern

                output[get_child(parameter, "name").to_s] = filter_pattern(pattern)
              end
            end
            output
          end

          def filter_pattern(pattern)
            to_return = pattern.to_s
            if to_return.start_with?('^')
              to_return = to_return[1..-1]
            end
            if to_return.start_with?('\A')
              to_return = to_return[2..-1]
            end
            if to_return.end_with?('$')
              to_return = to_return[0..-2]
            end
            if to_return.end_with?('\Z') || to_return.end_with?('\z')
              to_return = to_return[0..-3]
            end
            to_return
          end
        end
      end
    end
  end
end
