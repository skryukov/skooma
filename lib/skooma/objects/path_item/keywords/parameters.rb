# frozen_string_literal: true

module Skooma
  module Objects
    class PathItem
      module Keywords
        class Parameters < JSONSkooma::Keywords::Base
          self.key = "parameters"
          self.value_schema = :array_of_schemas
          self.schema_value_class = Objects::Parameter

          def evaluate(instance, result)
            result.skip_assertion
          end
        end
      end
    end
  end
end
