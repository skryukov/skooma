# frozen_string_literal: true

require "pp"

module Skooma
  module Matchers
    class ConformRequestSchema
      def initialize(schema, mapped_response)
        @schema = schema
        @mapped_response = mapped_response
      end

      def matches?(*)
        @result = @schema.evaluate(@mapped_response)
        @result.valid?
      end

      def description
        "conform request schema"
      end

      def failure_message
        <<~MSG
          ENV:
          #{pretty(@mapped_response)}

          Validation Result:
          #{pretty(@result.output(:skooma))}
        MSG
      end

      private

      def pretty(result)
        PP.pp(result, +"")
      end
    end
  end
end
