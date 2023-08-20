# frozen_string_literal: true

module Skooma
  module Objects
    class Operation
      module Keywords
        class RequestBody < JSONSkooma::Keywords::Base
          self.key = "requestBody"
          self.value_schema = :schema
          self.schema_value_class = Objects::RequestBody

          def evaluate(instance, result)
            return result.discard unless instance.key?("request")

            json.evaluate(instance["request"], result)
          end
        end
      end
    end
  end
end
