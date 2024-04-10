# frozen_string_literal: true

module Skooma
  module Objects
    class PathItem
      module Keywords
        class BaseOperation < JSONSkooma::Keywords::Base
          def evaluate(instance, result)
            return result.discard unless instance["method"] == key

            if json["responses"].nil? && instance["response"]
              return result.failure("Responses are not listed for #{key.upcase} #{instance["path"]}")
            end

            json.evaluate(instance, result)

            path_item_result = result.parent
            path_item_result = path_item_result.parent until path_item_result.key.start_with?("/")

            paths_result = path_item_result.parent
            paths_result.annotate(paths_result.annotation.merge("method" => key))

            return result.success if result.passed?

            path = paths_result.annotation["current_path"]

            result.failure("Path #{path}/#{key} is invalid")
          end
        end
      end
    end
  end
end
