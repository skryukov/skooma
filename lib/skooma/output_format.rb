# frozen_string_literal: true
module Skooma
  module OutputFormat
    class << self
      def call(result, **_options)
        return {"valid" => true} if result.valid?

        node_data(result, true)
      end

      private

      def node_data(node, first = false)
        data = {
          "instanceLocation" => node.instance.path.to_s,
          "relativeKeywordLocation" => node.relative_path.to_s,
          "keywordLocation" => node.path.to_s
        }

        child_data = node.children.filter_map do |_, child|
          node_data(child) unless child.valid?
        end

        if first || child_data.length > 1
          data["errors"] = child_data
        elsif child_data.length == 1
          data = child_data[0]
        elsif node.error
          data["error"] = node.error
        end

        data
      end
    end
  end
end
