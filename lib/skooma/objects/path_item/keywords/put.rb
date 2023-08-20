# frozen_string_literal: true

module Skooma
  module Objects
    class PathItem
      module Keywords
        class Put < BaseOperation
          self.key = "put"
          self.depends_on = %w[parameters]
          self.value_schema = :schema
          self.schema_value_class = Objects::Operation
        end
      end
    end
  end
end
