# frozen_string_literal: true

module Skooma
  module Objects
    class Base
      module Keywords
        class Deprecated < JSONSkooma::Keywords::BaseAnnotation
          self.key = "deprecated"
        end
      end
    end
  end
end
