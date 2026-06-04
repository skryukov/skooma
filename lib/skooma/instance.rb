# frozen_string_literal: true

module Skooma
  class Instance < JSONSkooma::JSONNode
    module Coercible
      def coerce(json)
        value = self&.value
        return self if value.nil?

        Coercible.coerce_value(value, json)
      end

      def self.coerce_value(value, json)
        case json["type"]
        when "integer"
          begin
            Integer(value, 10)
          rescue ArgumentError
            value
          end
        when "number"
          begin
            Float(value)
          rescue ArgumentError
            value
          end
        when "boolean"
          return true if value == "true"

          (value == "false") ? false : value
        when "object"
          value
          # convert_object(value, schema)
        when "array"
          coerce_array_items(value, json["items"])
        else
          value
        end
      end

      def self.coerce_array_items(value, items_schema)
        return value unless value.is_a?(Array)
        return value unless schema_object?(items_schema)

        value.map { |item| item.is_a?(String) ? coerce_value(item, items_schema) : item }
      end

      # Recursive coercion for *parameters* only. Parameter values arrive as
      # all-strings, so we descend into array items (positional `prefixItems`
      # first, then `items`) and object properties (`properties` first, then
      # `additionalProperties`), coercing each to its declared type.
      # Request/response *bodies* are only shallowly coerced (top level, via
      # `coerce` above), so a *nested* JSON body value like `{"count": "5"}`
      # against `integer` stays invalid.
      def deep_coerce(json)
        return if value.nil?

        Coercible.deep_coerce_value(value, json)
      end

      def self.deep_coerce_value(value, json)
        return value if value.nil?

        case json["type"]
        when "array"
          return value unless value.is_a?(Array)

          prefix_items = json["prefixItems"]
          items = json["items"]

          value.map.with_index do |item, index|
            schema = prefix_schema(prefix_items, index) || items
            schema_object?(schema) ? deep_coerce_value(item, schema) : item
          end
        when "object"
          return value unless value.is_a?(Hash)

          properties = json["properties"]
          additional_properties = json["additionalProperties"]

          value.each_with_object({}) do |(key, item), coerced|
            schema = properties.respond_to?(:key?) ? properties[key] : nil
            schema ||= additional_properties
            coerced[key] = schema_object?(schema) ? deep_coerce_value(item, schema) : item
          end
        else
          # Scalar schema: only scalar values are coercible. A structural value
          # here means a type mismatch (e.g. `deepObject` against a scalar
          # schema) — leave it for validation to reject rather than coerce.
          (value.is_a?(Hash) || value.is_a?(Array)) ? value : coerce_value(value, json)
        end
      end

      # True when `node` is a real subschema (a JSON object), excluding boolean
      # schemas like `items: true`.
      def self.schema_object?(node)
        node.is_a?(JSONSkooma::JSONSchema) && node.type == "object"
      end

      # The positional subschema for `index` when `prefixItems` is present.
      def self.prefix_schema(prefix_items, index)
        return unless prefix_items.is_a?(JSONSkooma::JSONNode) && prefix_items.type == "array"

        prefix_items[index]
      end
    end

    class Attribute < JSONSkooma::JSONNode
      include Coercible

      def initialize(value, **item_params)
        super(value, **item_params.merge(item_class: Attribute))
      end
    end

    class Headers < JSONSkooma::JSONNode
      def [](key)
        super(key.to_s.downcase)
      end

      private

      def map_object_value(value)
        value.map { |k, v| [k.to_s.downcase, Attribute.new(v, key: k.to_s, parent: self, **@item_params)] }.to_h
      end
    end

    class Response < Attribute
      private

      def parse_value(value)
        data = {}
        data["status"] = JSONSkooma::JSONNode.new(value.fetch("status"), key: "status", parent: self)
        data["headers"] = Headers.new(value.fetch("headers", {}), key: "headers", parent: self)
        body_value = parse_body(value["body"], data["headers"])
        data["body"] = Attribute.new(body_value, key: "body", parent: self)
        ["object", data]
      end

      def parse_body(body, headers)
        return nil unless body

        parser = BodyParsers[headers["Content-Type"]&.value&.split(";")&.first]
        parser ? parser.call(body, headers: headers) : body
      end
    end

    class Request < JSONSkooma::JSONNode
      private

      def parse_value(value)
        data = {}
        data["query"] = Attribute.new(value.fetch("query", ""), key: "query", parent: self)
        data["headers"] = Headers.new(value.fetch("headers", {}), key: "headers", parent: self)
        body_value = parse_body(value["body"], data["headers"])
        data["body"] = Attribute.new(body_value, key: "body", parent: self)
        ["object", data]
      end

      def parse_body(body, headers)
        return nil unless body

        parser = BodyParsers[headers["Content-Type"]&.value&.split(";")&.first]
        parser ? parser.call(body, headers: headers) : body
      end
    end

    private

    def parse_value(value)
      data = {
        "method" => JSONSkooma::JSONNode.new(value["method"], key: "method", parent: self),
        "path" => JSONSkooma::JSONNode.new(value["path"], key: "path", parent: self)
      }
      data["request"] = Request.new(value["request"], key: "request", parent: self) if value["request"]
      data["response"] = Response.new(value["response"], key: "response", parent: self) if value["response"]

      ["object", data]
    end
  end
end
