# frozen_string_literal: true

module Skooma
  module Objects
    class Operation
      module Keywords
        class Callbacks < JSONSkooma::Keywords::BaseAnnotation
          self.key = "callbacks"
        end
      end
    end
  end
end
