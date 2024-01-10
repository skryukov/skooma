# frozen_string_literal: true

module Skooma
  module Objects
    class Parameter
      module Keywords
        class Required < JSONSkooma::Keywords::Base
          self.key = "required"
          self.depends_on = %w[in name style explode allowReserved allowEmptyValue]

          def evaluate(instance, result)
            if json.value && ValueParser.call(instance, result)&.value.nil?
              result.failure("Parameter is required")
            end
          end
        end
      end
    end
  end
end
