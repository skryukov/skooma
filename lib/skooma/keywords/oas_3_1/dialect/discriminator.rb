# frozen_string_literal: true

module Skooma
  module Keywords
    module OAS31
      module Dialect
        class Discriminator < JSONSkooma::Keywords::BaseAnnotation
          self.key = "discriminator"
        end
      end
    end
  end
end
