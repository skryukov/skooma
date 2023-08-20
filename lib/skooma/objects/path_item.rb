# frozen_string_literal: true

module Skooma
  module Objects
    # Describes the operations available on a single path.
    # https://spec.openapis.org/oas/v3.1.0#path-item-object
    class PathItem < RefBase
      def kw_classes
        [
          Base::Keywords::Summary,
          Base::Keywords::Description,

          Keywords::Get,
          Keywords::Put,
          Keywords::Post,
          Keywords::Delete,
          Keywords::Options,
          Keywords::Head,
          Keywords::Patch,
          Keywords::Trace,

          Base::Keywords::Servers,
          Keywords::Parameters
        ]
      end
    end
  end
end
