# frozen_string_literal: true

module Skooma
  module Objects
    class PathItem
      module Keywords
        class Delete < BaseOperation
          self.key = "delete"
          self.depends_on = %w[parameters]
          self.value_schema = :schema
          self.schema_value_class = Objects::Operation
        end
      end
    end
  end
end
