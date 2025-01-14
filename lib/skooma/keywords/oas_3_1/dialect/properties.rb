# frozen_string_literal: true

module Skooma
  module Keywords
    module OAS31
      module Dialect
        class Properties < JSONSkooma::Keywords::Applicator::Properties
          self.key = "properties"
          self.instance_types = "object"
          self.value_schema = :object_of_schemas

          def evaluate(instance, result)
            annotation = []
            err_names = []
            instance.each do |name, item|
              next unless json.value.key?(name)

              result.call(item, name) do |subresult|
                json[name].evaluate(item, subresult)
                if ignored_with_only_key?(subresult)
                  subresult.discard
                elsif subresult.passed?
                  annotation << name
                else
                  err_names << name
                end
              end
            end

            return result.annotate(annotation) if err_names.empty?

            result.failure("Properties #{err_names.join(", ")} are invalid")
          end

          private

          def ignored_with_only_key?(subresult)
            return false unless json.root.enforce_access_modes?

            if subresult.parent.path.include?("responses")
              subresult.children["readOnly"]&.value == true
            else
              subresult.children["writeOnly"]&.value == true
            end
          end
        end
      end
    end
  end
end
