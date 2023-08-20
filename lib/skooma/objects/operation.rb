# frozen_string_literal: true

module Skooma
  module Objects
    # Describes a single API operation on a path.
    # https://spec.openapis.org/oas/v3.1.0#operation-object
    class Operation < Base
      def kw_classes
        [
          Base::Keywords::Tags,
          Base::Keywords::Summary,
          Base::Keywords::Description,
          Skooma::Keywords::OAS31::Dialect::ExternalDocs,
          Keywords::OperationId,
          Keywords::Parameters,
          Keywords::RequestBody,
          Keywords::Responses,
          Keywords::Callbacks,
          Base::Keywords::Deprecated,
          Base::Keywords::Security,
          Base::Keywords::Servers
        ]
      end

      def bootstrap(value)
        # always evaluate parameters to check parent parameters
        add_keyword(Keywords::Parameters.new(self, value["parameters"] || []))
      end
    end
  end
end
