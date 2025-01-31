# frozen_string_literal: true

module Skooma
  module Objects
    class OpenAPI
      module Keywords
        class Components < JSONSkooma::Keywords::Base
          self.key = "components"
          self.value_schema = :schema
          self.schema_value_class = Objects::Components

          # def initialize(parent_schema, value)
          #   super
          #   puts "components"
          #   puts parent_schema
          # end

          def each_schema(&block)
            return super unless json.type == "object"

            json.each_value do |s|
              s.each_value(&block)
            end
          end
        end
      end
    end
  end
end
