# frozen_string_literal: true

module Skooma
  module Objects
    class Parameter
      module Keywords
        class In < JSONSkooma::Keywords::BaseAnnotation
          self.key = "in"
        end
      end
    end
  end
end
