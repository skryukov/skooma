# frozen_string_literal: true

module Skooma
  module Objects
    # https://spec.openapis.org/oas/v3.1.0#parameter-object
    # Describes a single operation parameter.
    class Parameter < RefBase
      def kw_classes
        [
          Keywords::Name,
          Keywords::In,
          Base::Keywords::Description,
          Base::Keywords::Deprecated,
          Header::Keywords::Style,
          Header::Keywords::Explode,
          Keywords::AllowEmptyValue,
          Keywords::AllowReserved,
          Keywords::Required,
          Keywords::Schema,
          Header::Keywords::Example,
          Header::Keywords::Examples,
          Keywords::Content
        ]
      end
    end
  end
end
