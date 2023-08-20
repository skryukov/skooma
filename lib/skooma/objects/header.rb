# frozen_string_literal: true

module Skooma
  module Objects
    # https://spec.openapis.org/oas/v3.1.0#header-object
    # The Header Object follows the structure of the Parameter Object.
    class Header < RefBase
      def kw_classes
        [
          Base::Keywords::Description,
          Base::Keywords::Deprecated,
          Keywords::Style,
          Keywords::Explode,
          Keywords::Required,
          Keywords::Schema,
          Keywords::Example,
          Keywords::Examples,
          Keywords::Content
        ]
      end
    end
  end
end
