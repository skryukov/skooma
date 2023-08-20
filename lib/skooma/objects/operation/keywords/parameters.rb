# frozen_string_literal: true

module Skooma
  module Objects
    class Operation
      module Keywords
        class Parameters < JSONSkooma::Keywords::Base
          self.key = "parameters"
          self.value_schema = :array_of_schemas
          self.schema_value_class = Objects::Parameter

          def initialize(parent_schema, value)
            super
            keys = json.filter_map { |v| v["in"] && [v["in"].value, v["name"].value] }
            parent_params = (parent_schema.parent["parameters"] || [])
            parent_params.reject! do |v|
              v["in"] && keys.include?([v["in"].value, v["name"].value])
            end
            @parent_params = parent_params
          end

          def evaluate(instance, result)
            return result.discard unless instance.key?("request")
            return result.discard if json&.value&.empty? && @parent_params.empty?

            errors = []
            process_parameter(json, instance, result) do |subresult|
              errors << [subresult.schema_node["in"], subresult.schema_node["name"]] unless subresult.passed?
            end
            process_parameter(@parent_params, instance, result.parent.sibling(instance, "parameters")) do |subresult|
              key = [subresult.schema_node["in"], subresult.schema_node["name"]]
              errors << key unless subresult.passed?
            end
            return if errors.empty?

            result.failure("The following parameters are invalid: #{errors}")
          end

          private

          def process_parameter(v, instance, result)
            v.each.with_index do |param, index|
              result.call(instance["request"], index.to_s) do |subresult|
                param.evaluate(instance["request"], subresult)
                yield subresult
              end
            end
          end
        end
      end
    end
  end
end
