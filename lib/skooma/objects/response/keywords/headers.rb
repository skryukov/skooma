# frozen_string_literal: true

module Skooma
  module Objects
    class Response
      module Keywords
        class Headers < JSONSkooma::Keywords::Base
          self.key = "headers"
          self.value_schema = :object_of_schemas
          self.schema_value_class = Objects::Header

          def evaluate(instance, result)
            errors = []
            json.each do |key, schema|
              next if ignored_key?(key)

              result.call(instance["headers"], key) do |subresult|
                schema.evaluate(instance["headers"][key], subresult)

                errors << key unless subresult.passed?
              end
            end
            return if errors.empty?

            result.failure("The following headers are invalid: #{errors}")
          end

          private

          def ignored_key?(key)
            %w[accept content-type authorization].include?(key.downcase)
          end
        end
      end
    end
  end
end
