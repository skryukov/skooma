# frozen_string_literal: true

module Skooma
  module Matchers
    class ConformResponseSchema < ConformRequestSchema
      def initialize(skooma, mapped_response, expected)
        super(skooma, mapped_response)
        @expected = expected
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
