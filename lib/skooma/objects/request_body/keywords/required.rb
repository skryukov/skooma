# frozen_string_literal: true

module Skooma
  module Objects
    class RequestBody
      module Keywords
        class Required < JSONSkooma::Keywords::Base
          self.key = "required"

          def evaluate(instance, result)
            if json.value && instance["body"].value.nil?
              result.failure("Body is required")
            end
          end
        end
      end
    end
  end
end
