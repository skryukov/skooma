# frozen_string_literal: true

module Skooma
  module Objects
    # Describes a single response from an API Operation.
    # https://spec.openapis.org/oas/v3.1.0#responseObject
    class Response < RefBase
      def kw_classes
        [
          Base::Keywords::Description,
          Keywords::Headers,
          Keywords::Content,
          Keywords::Links
        ]
      end
    end
  end
end
