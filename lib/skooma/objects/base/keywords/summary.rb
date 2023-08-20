# frozen_string_literal: true

module Skooma
  module Objects
    class Base
      module Keywords
        class Summary < JSONSkooma::Keywords::BaseAnnotation
          self.key = "summary"
        end
      end
    end
  end
end
