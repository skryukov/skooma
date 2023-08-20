# frozen_string_literal: true

module Skooma
  class Instance < JSONSkooma::JSONNode
    module Coercible
      def coerce(json)
        value = self&.value
        return self if value.nil?

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
          # convert_array(value, schema)
          value
        else
          value
        end
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
        body_value = parse_body(value["body"], data["headers"]&.[]("Content-Type"))
        data["body"] = Attribute.new(body_value, key: "body", parent: self)
        ["object", data]
      end

      def parse_body(body, content_type)
        return nil unless body

        parser = BodyParsers[content_type&.split(";")&.first]
        parser ? parser.call(body) : body
      end
    end

    class Request < JSONSkooma::JSONNode
      private

      def parse_value(value)
        data = {}
        data["query"] = Attribute.new(value.fetch("query", ""), key: "query", parent: self)
        data["headers"] = Headers.new(value.fetch("headers", {}), key: "headers", parent: self)
        body_value = parse_body(value["body"], data["headers"]&.[]("Content-Type"))
        data["body"] = Attribute.new(body_value, key: "body", parent: self)
        ["object", data]
      end

      def parse_body(body, content_type)
        return nil unless body

        parser = BodyParsers[content_type&.split(";")&.first]
        parser ? parser.call(body) : body
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
