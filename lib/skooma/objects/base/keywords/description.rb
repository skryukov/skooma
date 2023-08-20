# frozen_string_literal: true

module Skooma
  module Objects
    class Base
      module Keywords
        class Description < JSONSkooma::Keywords::BaseAnnotation
          self.key = "description"
        end
      end
    end
  end
end
