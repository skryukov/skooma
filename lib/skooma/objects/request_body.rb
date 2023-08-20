# frozen_string_literal: true

module Skooma
  module Objects
    # Describes a single request body.
    # https://spec.openapis.org/oas/v3.1.0#request-body-object
    class RequestBody < RefBase
      def kw_classes
        [
          Base::Keywords::Description,
          Skooma::Objects::Response::Keywords::Content,
          Keywords::Required
        ]
      end
    end
  end
end
