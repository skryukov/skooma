# frozen_string_literal: true

module Skooma
  module Matchers
    class ConformSchema < ConformResponseSchema
      def description
        "conform schema with #{@expected} response code"
      end
    end
  end
end
