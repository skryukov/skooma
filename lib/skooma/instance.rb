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
        return value unless items_schema.is_a?(JSONSkooma::JSONSchema) && items_schema.type == "object"

        value.map { |item| item.is_a?(String) ? coerce_value(item, items_schema) : item }
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
