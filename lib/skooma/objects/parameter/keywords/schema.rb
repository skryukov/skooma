# frozen_string_literal: true

module Skooma
  module Objects
    class Parameter
      module Keywords
        class Schema < Skooma::Keywords::OAS31::Schema
          self.key = "schema"
          self.depends_on = %w[in name style explode allowReserved allowEmptyValue]

          def evaluate(instance, result)
            value = ValueParser.call(instance, result)
            return result.discard if value.nil?

            super(value, result)
          end
        end
      end
    end
  end
end
