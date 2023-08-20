# frozen_string_literal: true

module Skooma
  module Objects
    class Operation
      module Keywords
        class Responses < JSONSkooma::Keywords::Base
          self.key = "responses"
          self.value_schema = :object_of_schemas
          self.schema_value_class = Objects::Response

          def evaluate(instance, result)
            response = instance["response"] || {}
            return result.discard unless response["status"]

            status = find_status(response)

            return result.failure("Status #{response["status"]} not found for #{instance["method"].upcase} #{instance["path"]}") unless status

            result.annotate(status)
            result.call(response["status"], status) do |status_result|
              json[status].evaluate(response, status_result)

              if status_result.passed?
                result.annotate(status)
              else
                result.failure("Res #{response["status"]} is invalid")
              end
            end
          end

          private

          def find_status(response)
            response_status = response["status"].to_s
            if json.key?(response_status)
              response_status
            elsif json.key?("#{response_status[0]}XX")
              "#{response_status[0]}XX"
            elsif json.key?("default")
              "default"
            end
          end
        end
      end
    end
  end
end
