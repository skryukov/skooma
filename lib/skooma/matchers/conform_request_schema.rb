# frozen_string_literal: true

require "pp"

module Skooma
  module Matchers
    class ConformRequestSchema
      def initialize(skooma, mapped_response)
        @skooma = skooma
        @schema = skooma.schema
        @mapped_response = mapped_response
      end

      def matches?(*)
        @result = @schema.evaluate(@mapped_response)

        @skooma.coverage.track_request(@result) if @mapped_response["response"]

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
