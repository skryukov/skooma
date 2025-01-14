# frozen_string_literal: true

module Skooma
  module Keywords
    module OAS31
      module Dialect
        class Required < JSONSkooma::Keywords::Validation::Required
          self.key = "required"
          self.instance_types = "object"
          self.depends_on = %w[properties]

          def evaluate(instance, result)
            missing = required_keys.reject { |key| instance.key?(key) }
            return if missing.none?

            if json.root.enforce_access_modes?
              properties_schema = result.sibling(instance, "properties")&.schema_node || {}
              only_key = result.path.include?("responses") ? "writeOnly" : "readOnly"
              ignore = []
              missing.each do |name|
                next unless properties_schema.key?(name)

                result.call(nil, name) do |subresult|
                  properties_schema[name].evaluate(nil, subresult)
                  ignore << name if annotation_exists?(subresult, key: only_key)
                  subresult.discard
                end
              end

              return if (missing - ignore).none?
            end

            result.failure(missing_keys_message(missing))
          end

          private

          def annotation_exists?(result, key:)
            return result if result.key == key && result.annotation

            result.each_children do |child|
              return child if annotation_exists?(child, key: key)
            end

            nil
          end
        end
      end
    end
  end
end
