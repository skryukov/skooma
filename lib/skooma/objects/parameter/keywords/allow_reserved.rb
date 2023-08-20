# frozen_string_literal: true

module Skooma
  module Objects
    class Parameter
      module Keywords
        class AllowReserved < JSONSkooma::Keywords::BaseAnnotation
          self.key = "allowReserved"
        end
      end
    end
  end
end
