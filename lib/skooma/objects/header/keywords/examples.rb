# frozen_string_literal: true

module Skooma
  module Objects
    class Header
      module Keywords
        class Examples < JSONSkooma::Keywords::BaseAnnotation
          self.key = "examples"
        end
      end
    end
  end
end
