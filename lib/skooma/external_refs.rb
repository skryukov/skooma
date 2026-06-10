# frozen_string_literal: true

module Skooma
  # External $ref resolution: upstream treats a referenced document as a single
  # JSONSchema and errors out when the fragment points at a non-schema node
  # inside a raw map (e.g. `responses.yaml#/Users`). Here we load the raw
  # document, navigate to the fragment, and wrap the subtree as the referrer's
  # own class so OpenAPI semantics are preserved.
  module ExternalRefs
    def resolve_ref(uri)
      super
    rescue JSONSkooma::UnexpectedSchemaClassError
      load_external_ref(resolve_uri(uri))
    end

    private

    def load_external_ref(resolved_uri)
      base_uri = resolved_uri.dup.tap { |u| u.fragment = nil }
      raw_doc = registry.load_json(base_uri)

      data =
        if resolved_uri.fragment.nil? || resolved_uri.fragment.empty?
          raw_doc
        else
          JSONSkooma::JSONPointer.new(resolved_uri.fragment).eval(raw_doc)
        end

      raise JSONSkooma::RegistryError, "Could not resolve $ref #{resolved_uri}" if data.nil?

      wrap_external_data(data, resolved_uri)
    end

    def wrap_external_data(data, uri)
      wrapped = self.class.new(
        data,
        parent: root,
        registry: registry,
        cache_id: cache_id,
        uri: uri,
        metaschema_uri: metaschema_uri
      )
      wrapped.resolve_references
      wrapped
    end
  end
end
