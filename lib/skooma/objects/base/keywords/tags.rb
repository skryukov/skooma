# frozen_string_literal: true

module Skooma
  module Objects
    class Base
      module Keywords
        class Tags < JSONSkooma::Keywords::BaseAnnotation
          self.key = "tags"
        end
      end
    end
  end
end
