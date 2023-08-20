# frozen_string_literal: true

module Skooma
  module Objects
    class OpenAPI
      module Keywords
        # Map[string, Path Item Object | Reference Object] ]
        # example: https://github.com/OAI/OpenAPI-Specification/blob/main/examples/v3.1/webhook-example.yaml
        class Webhooks < JSONSkooma::Keywords::BaseAnnotation
          self.key = "webhooks"
        end
      end
    end
  end
end
