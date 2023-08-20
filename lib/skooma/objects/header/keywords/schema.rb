# frozen_string_literal: true

module Skooma
  module Objects
    class Header
      module Keywords
        class Schema < Skooma::Keywords::OAS31::Schema
          self.key = "schema"

          def evaluate(instance, result)
            return if instance.value.nil?

            super
          end
        end
      end
    end
  end
end
