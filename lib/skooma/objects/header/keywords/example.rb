# frozen_string_literal: true

module Skooma
  module Objects
    class Header
      module Keywords
        class Example < JSONSkooma::Keywords::BaseAnnotation
          self.key = "example"
        end
      end
    end
  end
end
