# frozen_string_literal: true

module Skooma
  module Objects
    class Parameter
      module Keywords
        class Required < JSONSkooma::Keywords::Base
          self.key = "required"
          self.depends_on = %w[in name style explode allowReserved allowEmptyValue]

          def evaluate(instance, result)
            return unless json.value

            value = ValueParser.call(instance, result, array: ValueParser.array_param?(parent_schema))
            if value&.value.nil?
              result.failure("Parameter is required")
            end
          end
        end
      end
    end
  end
end
