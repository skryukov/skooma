# frozen_string_literal: true

module Skooma
  module Objects
    class Header
      module Keywords
        class Required < JSONSkooma::Keywords::Base
          self.key = "required"

          def evaluate(instance, result)
            if json.value && instance.value.nil?
              result.failure("Header is required")
            end
          end
        end
      end
    end
  end
end
