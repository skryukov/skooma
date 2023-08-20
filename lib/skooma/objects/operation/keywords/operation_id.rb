# frozen_string_literal: true

module Skooma
  module Objects
    class Operation
      module Keywords
        class OperationId < JSONSkooma::Keywords::BaseAnnotation
          self.key = "operationId"
        end
      end
    end
  end
end
