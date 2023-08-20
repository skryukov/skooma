# frozen_string_literal: true

module Skooma
  module Objects
    class Header
      module Keywords
        class Content < JSONSkooma::Keywords::Base
          self.key = "content"
          self.value_schema = :object_of_schemas
          self.schema_value_class = Objects::MediaType

          def evaluate(instance, result)
            return if instance&.value.nil?

            media_type = result.root.instance["response"]["headers"]["Content-Type"]&.split(";")&.first&.strip&.downcase
            media_type_object, matched_media_type = find_media_type(media_type)

            return result.discard unless media_type_object

            result.annotate(matched_media_type)
            result.call(instance, matched_media_type) do |media_type_result|
              media_type_object.evaluate(instance, media_type_result)
              result.failure("Invalid content") unless media_type_result.passed?
            end
          end

          private

          # The key is a media type or media type range and the value describes it.
          # For requests that match multiple keys, only the most specific key is applicable.
          # e.g. text/plain overrides text/*
          def find_media_type(media_type)
            matched_media_type =
              if json.key?(media_type)
                media_type
              elsif media_type &&
                  (key = "#{media_type.split("/").first}/*") &&
                  json.key?(key)
                key
              elsif json.key?("*/*")
                "*/*"
              end

            [json[matched_media_type], matched_media_type]
          end
        end
      end
    end
  end
end
