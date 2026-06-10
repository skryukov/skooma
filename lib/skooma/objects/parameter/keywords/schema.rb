# frozen_string_literal: true

module Skooma
  module Objects
    class Parameter
      module Keywords
        class Schema < Skooma::Keywords::OAS31::Schema
          self.key = "schema"
          self.depends_on = %w[in name style explode allowReserved allowEmptyValue]

          def evaluate(instance, result)
            value = ValueParser.call(instance, result, array: ValueParser.array_param?(parent_schema))
            return result.discard if value.nil?

            # Parameters coerce deeply (their values arrive as all-strings);
            # bodies keep OAS31::Schema's shallow `coerce`, so body validation
            # is unaffected.
            json.evaluate(value.deep_coerce(json), result)
          end
        end
      end
    end
  end
end
