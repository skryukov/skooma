# frozen_string_literal: true

module Skooma
  module Objects
    class OpenAPI
      module Keywords
        class Info < JSONSkooma::Keywords::BaseAnnotation
          self.key = "info"
        end
      end
    end
  end
end
