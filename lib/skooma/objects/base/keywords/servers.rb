# frozen_string_literal: true

module Skooma
  module Objects
    class Base
      module Keywords
        class Servers < JSONSkooma::Keywords::BaseAnnotation
          self.key = "servers"
        end
      end
    end
  end
end
