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
            "simple" => ",",
            "spaceDelimited" => " ",
            "pipeDelimited" => "|"
          }.freeze

          # Default `style` per parameter location (OpenAPI 3.1 parameter object).
          DEFAULT_STYLE = {
            "query" => "form",
            "path" => "simple",
            "header" => "simple",
            "cookie" => "form"
          }.freeze

          class << self
            def call(instance, result, schema: nil)
              location = result.sibling(instance, "in")&.annotation
              raise Error, "Missing `in` key #{result.path}" unless location

              key = result.sibling(instance, "name")&.annotation
              raise Error, "Missing `name` key #{result.path}" unless key

              case location
              when "query"
                query_param_value(instance, result, key, schema: schema)
              when "header"
                header_param_value(instance, result, key, schema: schema)
              when "path"
                path_param_value(instance, result, key, schema: schema)
              when "cookie"
                cookie_param_value(instance, result, key, schema: schema)
              else
                raise Error, "Unknown location: #{location}"
              end
            end

            private

            # The declared shape of the parameter value: :array, :object, or
            # :primitive (scalars, missing schemas, and `content` params).
            def shape_of(schema)
              return :primitive unless schema.is_a?(JSONSkooma::JSONSchema) && schema.type == "object"

              case schema["type"]&.value
              when "array" then :array
              when "object" then :object
              else :primitive
              end
            end

            def query_param_value(instance, result, key, schema:)
              shape = shape_of(schema)

              # `deepObject` spreads an object across bracketed keys
              # (`filter[a]=1&filter[b]=2`) and is the only style that consumes
              # more than one query key, so it is handled before the scalar/array
              # path.
              if result.sibling(instance, "style")&.annotation == "deepObject"
                return deep_object_value(instance, key)
              end

              if shape == :object
                return form_object_value(instance, result, key, schema)
              end

              array = shape == :array
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

            # Header values are a single string; an array is delimited inline
            # (`simple` style, comma-separated). `explode` does not change the
            # serialization for headers, so it is not consulted. Object-valued
            # headers are out of scope.
            def header_param_value(instance, result, key, schema:)
              attribute = instance["headers"][key]
              return attribute unless shape_of(schema) == :array
              return attribute if attribute.nil? || attribute.value.nil?

              Instance::Attribute.new(
                split_delimited(attribute.value, style_for(result, instance, "header")),
                key: key,
                parent: instance["headers"]
              )
            end

            # Path values are a single captured segment. `simple` (the default)
            # is comma-delimited; `label` carries a `.` prefix and `matrix` a
            # `;name=` prefix, and for arrays `explode` switches the item
            # separator. Objects flatten into the segment as key/value pairs —
            # comma-interleaved (`role,admin`) or `=`-joined (`role=admin`)
            # when exploded.
            def path_param_value(instance, result, key, schema:)
              raw = path_attributes(result)[key]
              return nil if raw.nil?

              style = style_for(result, instance, "path")
              explode = result.sibling(instance, "explode")&.annotation || false
              value =
                case shape_of(schema)
                when :array
                  deserialize_path_array(raw, key, style, explode)
                when :object
                  deserialize_path_object(raw, key, style, explode)
                else
                  strip_path_prefix(raw, key, style)
                end

              Instance::Attribute.new(value, key: "path", parent: instance["path"])
            end

            def path_attributes(result)
              path_item_result = result.parent
              path_item_result = path_item_result.parent until path_item_result.key.start_with?("/")
              path_item_result.annotation["path_attributes"]
            end

            def strip_path_prefix(raw, name, style)
              case style
              when "label" then raw.delete_prefix(".")
              when "matrix" then raw.delete_prefix(";#{name}=")
              else raw
              end
            end

            def deserialize_path_array(raw, name, style, explode)
              case style
              when "label"
                strip_path_prefix(raw, name, style).split(explode ? "." : ",")
              when "matrix"
                if explode
                  # `;id=3;id=4;id=5` — keep only this parameter's pairs
                  raw.delete_prefix(";").split(";").map { |pair|
                    pair_name, pair_value = pair.split("=", 2)
                    pair_value if pair_name == name
                  }.compact
                else
                  # `;id=3,4,5`
                  strip_path_prefix(raw, name, style).split(",")
                end
              else # simple: `3,4,5`
                raw.split(",")
              end
            end

            # Object path params flatten properties into the segment:
            #   simple:          `role,admin,name,Alex`
            #   simple explode:  `role=admin,name=Alex`
            #   label:           `.role,admin,name,Alex`
            #   label explode:   `.role=admin.name=Alex`
            #   matrix:          `;point=role,admin,name,Alex`
            #   matrix explode:  `;role=admin;name=Alex`
            # A malformed flattening (odd member count, missing `=`) returns the
            # raw string so schema validation rejects it.
            def deserialize_path_object(raw, name, style, explode)
              members =
                if explode
                  body = (style == "matrix") ? raw.delete_prefix(";") : strip_path_prefix(raw, name, style)
                  separator = {"label" => ".", "matrix" => ";"}.fetch(style, ",")
                  body.split(separator).map { |pair| pair.split("=", 2) }
                else
                  strip_path_prefix(raw, name, style).split(",").each_slice(2).to_a
                end

              return raw unless members.all? { |pair| pair.size == 2 }

              members.to_h
            end

            # Cookies carry one string per name; an array is a delimited inline
            # value (`form` style, comma-separated). `explode` is not consulted
            # because cookies cannot repeat a name. Object-valued cookies are
            # out of scope.
            def cookie_param_value(instance, result, key, schema:)
              raw = parse_cookies(instance["headers"]["Cookie"]&.value)[key]
              return nil if raw.nil?

              value = (shape_of(schema) == :array) ? split_delimited(raw, style_for(result, instance, "cookie")) : raw
              Instance::Attribute.new(value, key: key, parent: instance["headers"])
            end

            # deepObject: gather the bracketed properties of `key` into a hash.
            # Property values stay strings; type coercion happens later via
            # Instance#deep_coerce against the object's `properties` schema.
            # (Nested objects and array-valued properties are out of scope.)
            def deep_object_value(instance, key)
              prefix = "#{key}["
              object = {}
              parse_query(instance["query"]&.value).each do |param_key, values|
                next unless param_key.start_with?(prefix) && param_key.end_with?("]")

                property = param_key.delete_prefix(prefix).delete_suffix("]")
                next if property.empty?

                object[property] = values.last
              end
              return nil if object.empty?

              Instance::Attribute.new(object, key: key, parent: instance["query"])
            end

            # `form`-style object query params (the default style). Exploded
            # objects drop the parameter name entirely — each declared property
            # becomes its own query key (`?x=1&y=2`) — so members are gathered
            # by matching the schema's `properties` names; `additionalProperties`
            # members cannot be recognized and are out of scope. Non-exploded
            # objects flatten under the parameter's own name (`?point=x,1,y,2`).
            def form_object_value(instance, result, key, schema)
              params = parse_query(instance["query"]&.value)
              explode = result.sibling(instance, "explode")&.annotation
              explode = true if explode.nil?

              if explode
                properties = schema["properties"]
                return nil unless properties.respond_to?(:each)

                object = {}
                properties.each do |property, _subschema|
                  values = params[property]
                  object[property] = values.last unless values.nil?
                end
                return nil if object.empty?

                Instance::Attribute.new(object, key: key, parent: instance["query"])
              else
                values = params[key]
                return nil if values.nil? || values.last.nil?

                members = values.last.split(",").each_slice(2).to_a
                # A malformed flattening (odd member count) stays a raw string
                # so schema validation rejects it.
                value = (members.all? { |pair| pair.size == 2 }) ? members.to_h : values.last
                Instance::Attribute.new(value, key: key, parent: instance["query"])
              end
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

            # Cookie values are opaque (RFC 6265): split into name=value pairs
            # but do not percent-decode (unlike query strings), so values such as
            # base64 tokens stay intact.
            def parse_cookies(cookie_string)
              cookies = {}
              cookie_string.to_s.split(/;\s*/).each do |pair|
                name, value = pair.split("=", 2)
                next if name.nil? || name.empty?

                cookies[name] = value
              end

              cookies
            end

            def deserialize_array(values, instance, result)
              style = style_for(result, instance, "query")
              explode = result.sibling(instance, "explode")&.annotation
              explode = style == "form" if explode.nil?

              # exploded arrays are serialized as repeated keys (`ids=1&ids=2`)
              return values.compact if explode

              split_delimited(values.last, style)
            end

            def split_delimited(raw, style)
              raw.split(ARRAY_STYLE_DELIMITERS.fetch(style, ","))
            end

            def style_for(result, instance, location)
              result.sibling(instance, "style")&.annotation || DEFAULT_STYLE.fetch(location, "form")
            end
          end
        end
      end
    end
  end
end
