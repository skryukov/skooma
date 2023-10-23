# frozen_string_literal: true

require "cgi"

module Skooma
  module Objects
    class Parameter
      module Keywords
        module ValueParser
          class << self
            def call(instance, result)
              type = result.sibling(instance, "in")&.annotation
              raise Error, "Missing `in` key #{result.path}" unless type

              key = result.sibling(instance, "name")&.annotation
              raise Error, "Missing `name` key #{instance.path}: #{key}" unless key

              case type
              when "query"
                parse_query(instance)[key]
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

            private

            def parse_query(instance)
              params = {}
              instance["query"]&.value.to_s.split(/[&;]/).each do |pairs|
                key, value = pairs.split("=", 2).collect { |v| CGI.unescape(v) }
                next unless key

                params[key] = value
              end

              Instance::Attribute.new(
                params,
                key: "query",
                parent: instance["query"]
              )
            end

            def style(value, instance, result)
              case result.sibling(instance, "style")
              when "simple"
                value
              when "label"
                value.split(".")
              when "matrix"
                value.split(";")
              when "form"
                value.split("&")
              when "spaceDelimited"
                value.split(" ")
              when "pipeDelimited"
                value.split("|")
              when "deepObject"
                raise Error, "Not implemented yet"
              else
                raise Error, "Unknown style: #{result.sibling(instance, "style")}"
              end
            end
          end
        end
      end
    end
  end
end
