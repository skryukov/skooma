# frozen_string_literal: true

module Skooma
  module Objects
    class Header
      module Keywords
        class Explode < JSONSkooma::Keywords::BaseAnnotation
          self.key = "explode"
        end
      end
    end
  end
end
