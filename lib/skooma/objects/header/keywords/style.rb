# frozen_string_literal: true

module Skooma
  module Objects
    class Header
      module Keywords
        class Style < JSONSkooma::Keywords::BaseAnnotation
          self.key = "style"
        end
      end
    end
  end
end
