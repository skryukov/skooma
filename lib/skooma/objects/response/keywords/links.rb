# frozen_string_literal: true

module Skooma
  module Objects
    class Response
      module Keywords
        class Links < JSONSkooma::Keywords::BaseAnnotation
          self.key = "links"
        end
      end
    end
  end
end
