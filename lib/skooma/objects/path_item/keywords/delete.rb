# frozen_string_literal: true

module Skooma
  module Objects
    class PathItem
      module Keywords
        class Delete < BaseOperation
          self.key = "options"
          self.depends_on = %w[parameters]
          self.value_schema = :schema
          self.schema_value_class = Objects::Operation
        end
      end
    end
  end
end
