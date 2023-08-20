# frozen_string_literal: true

module Skooma
  module Objects
    # A simple object to allow referencing other components in the OpenAPI document.
    # https://spec.openapis.org/oas/v3.1.0#referenceObject
    class RefBase < Base
      # This object cannot be extended with additional properties
      # and any properties added SHALL be ignored.
      def resolve_keywords(value)
        return super unless value.key?("$ref")

        resolve_ref_keywords(value)
      end

      def ref_kw_classes
        [
          JSONSkooma::Keywords::Core::Ref,
          Base::Keywords::Summary,
          Base::Keywords::Description
        ]
      end

      def resolve_ref_keywords(value)
        ref_kw_classes.each do |kw_class|
          next unless value.key?(kw_class.key)

          add_keyword(kw_class.new(self, value[kw_class.key]))
        end
      end
    end
  end
end
