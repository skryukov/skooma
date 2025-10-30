# frozen_string_literal: true

module Skooma
  module Matchers
    class ConformResponseSchema < ConformRequestSchema
      def initialize(skooma, mapped_response, expected)
        super(skooma, mapped_response)

        @expected = expected

        case expected
        when Symbol
          @expected_code = Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(expected)
        when Integer
          @expected_code = expected
        else
          raise ArgumentError, "Expected symbol or number, got expected=#{expected.inspect}"
        end
      end

      def description
        "conform response schema with #{@expected} response code"
      end

      def matches?(*)
        return false unless status_matches?

        super
      end

      def failure_message
        return "Expected #{@expected} status code, but got #{@mapped_response["response"]["status"]}" unless status_matches?

        super
      end

      private

      def status_matches?
        @mapped_response["response"]["status"] == @expected
      end
    end
  end
end
