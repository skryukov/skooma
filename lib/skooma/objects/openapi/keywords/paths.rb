# frozen_string_literal: true

require 'pp'

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
            @parent_schema = parent_schema
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
              # now you have @parent_schema where everything is initialized
              # puts pretty(@parent_schema)
              # puts pretty(subschema)
              pattern_hash = create_hash_of_patterns(subschema)

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

          def create_hash_of_patterns(subschema)
            output = {}
            for method in subschema.keys do
              for parameter in subschema[method]["parameters"] do
                if parameter.key?("in") && parameter["in"] == "path"
                  pattern = "[^/?#]+"
                  if parameter.key?("pattern")
                    pattern = parameter["pattern"]
                  else
                    if parameter.key?("schema") && parameter["schema"].key?("pattern")
                      pattern = parameter["schema"]["pattern"]
                    end
                  end
                  if parameter.key?("required") && !parameter["require"]
                    pattern = "(#{pattern})?"
                  end
                  #TODO: work with other format
                  if parameter.key?("name")
                    output[parameter["name"].to_s] = pattern
                  end
                end
              end
            end
            output
          end

          def pretty(result)
            PP.pp(result, +"")
          end
        end
      end
    end
  end
end
