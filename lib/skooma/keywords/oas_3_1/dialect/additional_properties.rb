# frozen_string_literal: true

module Skooma
  module Keywords
    module OAS31
      module Dialect
        class AdditionalProperties < JSONSkooma::Keywords::Applicator::AdditionalProperties
          self.key = "additionalProperties"
          self.instance_types = "object"
          self.value_schema = :schema
          self.depends_on = %w[properties patternProperties]

          def evaluate(instance, result)
            known_property_names = result.sibling(instance, "properties")&.schema_node&.keys || []
            known_property_patterns = (result.sibling(instance, "patternProperties")&.schema_node&.keys || [])
              .map { |pattern| Regexp.new(pattern) }

            forbidden = []

            if json.root.enforce_access_modes?
              only_key = result.path.include?("responses") ? "writeOnly" : "readOnly"
              properties_result = result.sibling(instance, "properties")
              instance.each_key do |name|
                res = properties_result&.children&.[](instance[name]&.path)&.[]name
                forbidden << name.tap { puts "adding #{name}" } if res && annotation_exists?(res, key: only_key)
              end
            end

            annotation = []
            error = []

            instance.each do |name, item|
              if forbidden.include?(name) || !known_property_names.include?(name) && known_property_patterns.none? { |pattern| pattern.match?(name) }
                if json.evaluate(item, result).passed?
                  annotation << name
                else
                  error << name
                  # reset to success for the next iteration
                  result.success
                end
              end
            end
            return result.annotate(annotation) if error.empty?

            result.failure(error)
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
