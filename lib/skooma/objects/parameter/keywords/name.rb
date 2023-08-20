# frozen_string_literal: true

module Skooma
  module Objects
    class Parameter
      module Keywords
        class Name < JSONSkooma::Keywords::BaseAnnotation
          self.key = "name"
        end
      end
    end
  end
end
