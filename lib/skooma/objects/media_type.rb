# frozen_string_literal: true

module Skooma
  module Objects
    # https://spec.openapis.org/oas/v3.1.0#media-type-object
    class MediaType < Base
      def kw_classes
        [
          Keywords::Schema
        ]
      end

      module Keywords
        # Applies the Media Type Object's `encoding` field before schema
        # validation. For `multipart/*` and `application/x-www-form-urlencoded`
        # bodies, fields arrive as raw strings; a field whose `contentType` is
        # a JSON media type (explicitly via `encoding`, or by the multipart
        # default for object-typed properties) is decoded first, so its schema
        # validates the structured value rather than the serialized string.
        class Schema < Skooma::Keywords::OAS31::Schema
          self.key = "schema"

          URLENCODED = "application/x-www-form-urlencoded"

          def evaluate(instance, result)
            super(apply_encoding(instance), result)
          end

          private

          def apply_encoding(instance)
            return instance unless form_media_type?

            value = instance.value
            return instance unless value.is_a?(Hash)

            encoding = parent_schema["encoding"]
            decoded = value.each_with_object({}) do |(field, field_value), hash|
              hash[field] = decode_field(field, field_value, encoding)
            end

            Instance::Attribute.new(decoded, key: instance.key, parent: instance.parent)
          end

          def media_type
            parent_schema.key.to_s.split(";").first.to_s.strip.downcase
          end

          def form_media_type?
            media_type.start_with?("multipart/") || media_type == URLENCODED
          end

          def decode_field(field, value, encoding)
            content_type = field_content_type(field, encoding)
            return value unless json_media_type?(content_type)

            parser = BodyParsers[content_type]
            case value
            when String
              parser.call(value)
            when Array
              value.map { |item| item.is_a?(String) ? parser.call(item) : item }
            else
              value
            end
          end

          def field_content_type(field, encoding)
            explicit = encoding&.[](field)&.[]("contentType")&.value
            return explicit if explicit

            # The spec's default contentType for multipart object-typed
            # properties is application/json.
            return unless media_type.start_with?("multipart/")

            property = json["properties"]&.[](field)
            return unless property.is_a?(JSONSkooma::JSONSchema)

            "application/json" if property["type"]&.value == "object"
          end

          def json_media_type?(content_type)
            return false if content_type.nil?

            normalized = content_type.split(";").first.to_s.strip.downcase
            normalized == "application/json" || normalized.end_with?("+json")
          end
        end
      end
    end
  end
end
