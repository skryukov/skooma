# frozen_string_literal: true

module Skooma
  module Objects
    class Parameter
      module Keywords
        class AllowEmptyValue < JSONSkooma::Keywords::BaseAnnotation
          self.key = "allowEmptyValue"
        end
      end
    end
  end
end
