# frozen_string_literal: true

module Skooma
  module Keywords
    module OAS31
      module Dialect
        # Discriminator keyword is an annotation keyword,
        # it does not affect validation of allOf/anyOf/oneOf schemas.
        # See https://github.com/OAI/OpenAPI-Specification/pull/2618
        class Discriminator < JSONSkooma::Keywords::Base
          self.key = "discriminator"

          def evaluate(instance, result)
            value = instance[json["propertyName"]]
            uri = mapped_uri(value)
            return result.failure("Could not resolve discriminator for value `#{value.inspect}`") if uri.nil?

            parent_schema.registry.schema(
              uri,
              metaschema_uri: parent_schema.metaschema_uri,
              cache_id: parent_schema.cache_id
            )
            result.annotate(uri)
          rescue JSONSkooma::RegistryError => e
            result.failure("Could not resolve discriminator mapping: #{e.message}")
          end

          private

          def mapped_uri(value)
            uri = json["mapping"]&.fetch(value, value)
            return if uri.nil?

            uri = "#/components/schemas/#{uri}" unless uri.start_with?("#") || uri.include?("/")
            uri = URI.parse(uri)
            return uri if uri.absolute?

            parent_schema.base_uri + uri if parent_schema.base_uri
          end
        end
      end
    end
  end
end
