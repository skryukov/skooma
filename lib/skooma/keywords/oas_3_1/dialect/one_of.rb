# frozen_string_literal: true

module Skooma
  module Keywords
    module OAS31
      module Dialect
        class OneOf < JSONSkooma::Keywords::Applicator::OneOf
          self.key = "oneOf"
          self.value_schema = :array_of_schemas
          self.depends_on = %w[discriminator]

          def evaluate(instance, result)
            discriminator_schema = result.sibling(instance, "discriminator")&.annotation
            reorder_json(discriminator_schema)

            super
          end

          private

          def reorder_json(discriminator_schema)
            return unless discriminator_schema

            first = @json.delete_at(@json.index { |schema| resolve_uri(schema["$ref"]) == discriminator_schema })
            @json.unshift first if first
          end

          def resolve_uri(uri)
            uri = URI.parse(uri)
            return uri if uri.absolute?

            parent_schema.base_uri + uri if parent_schema.base_uri
          end
        end
      end
    end
  end
end
