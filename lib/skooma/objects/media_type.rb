# frozen_string_literal: true

module Skooma
  module Objects
    # https://spec.openapis.org/oas/v3.1.0#media-type-object
    class MediaType < Base
      def kw_classes
        [
          Keywords::OAS31::Schema
        ]
      end
    end
  end
end
