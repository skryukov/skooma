# frozen_string_literal: true

require "pp"

module Skooma
  module Matchers
    class BeValidDocument
      def matches?(actual)
        @actual = actual
        return false unless comparable?

        @result = @actual.validate
        @result.valid?
      end

      def description
        "be a valid OpenAPI document"
      end

      def failure_message
        return "expected value to be an OpenAPI object" unless comparable?

        <<~MSG
          must valid against OpenAPI specification:
          #{pretty(@result.output(:detailed))}
        MSG
      end

      private

      def pretty(result)
        PP.pp(result, +"")
      end

      def comparable?
        @actual.is_a?(Skooma::Objects::OpenAPI)
      end
    end
  end
end
