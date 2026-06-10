# frozen_string_literal: true

module Skooma
  module Objects
    # JSON Schema value inside an OpenAPI `schema:` keyword. Subclass of
    # JSONSkooma::JSONSchema that participates in external $ref resolution.
    class Schema < JSONSkooma::JSONSchema
      include ExternalRefs
    end
  end
end
