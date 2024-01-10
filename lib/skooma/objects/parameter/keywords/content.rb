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

            super(ValueParser.call(instance, result), result)
          end
        end
      end
    end
  end
end
