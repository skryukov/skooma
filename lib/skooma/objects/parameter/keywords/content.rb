# frozen_string_literal: true

module Skooma
  module Objects
    class Parameter
      module Keywords
        class Content < Header::Keywords::Content
          self.key = "content"
          self.value_schema = :object_of_schemas
          self.schema_value_class = Objects::MediaType
          self.depends_on = %w[in name style explode allowReserved allowEmptyValue]

          def evaluate(instance, result)
            return if instance.value.nil?

            value = ValueParser.call(instance, result)
            return result.discard if value.nil?

            # A parameter's `content` declares the media type its value is
            # serialized in (typically exactly one entry). Parse the raw value
            # with the matching body parser, then validate the parsed value
            # against that media type's schema. (The header version picks the
            # media type from the response Content-Type, which is wrong here.)
            json.each do |media_type, media_type_object|
              parsed = Instance::Attribute.new(
                BodyParsers[media_type].call(value.value),
                key: value.key,
                parent: value.parent
              )
              result.call(parsed, media_type) do |media_type_result|
                media_type_object.evaluate(parsed, media_type_result)
                result.failure("Invalid content for media type #{media_type}") unless media_type_result.passed?
              end
            end
          end
        end
      end
    end
  end
end
