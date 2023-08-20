# frozen_string_literal: true

module Skooma
  module Objects
    class Base
      module Keywords
        class Security < JSONSkooma::Keywords::BaseAnnotation
          self.key = "security"
        end
      end
    end
  end
end
