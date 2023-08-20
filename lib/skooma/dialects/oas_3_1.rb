# frozen_string_literal: true

module Skooma
  module Dialects
    module OAS31
      class << self
        def call(registry, **options)
          registry.add_source(
            "https://spec.openapis.org/oas/3.1/",
            JSONSkooma::Sources::Local.new(File.join(DATA_DIR, "oas-3.1").to_s, suffix: ".json")
          )

          registry.add_vocabulary(
            "https://spec.openapis.org/oas/3.1/vocab/base",
            Skooma::Keywords::OAS31::Dialect::Discriminator,
            Skooma::Keywords::OAS31::Dialect::Xml,
            Skooma::Keywords::OAS31::Dialect::ExternalDocs,
            Skooma::Keywords::OAS31::Dialect::Example
          )

          registry.add_metaschema(
            "https://spec.openapis.org/oas/3.1/dialect/base",
            "https://json-schema.org/draft/2020-12/vocab/core",
            "https://json-schema.org/draft/2020-12/vocab/applicator",
            "https://json-schema.org/draft/2020-12/vocab/unevaluated",
            "https://json-schema.org/draft/2020-12/vocab/validation",
            "https://json-schema.org/draft/2020-12/vocab/format-annotation",
            "https://json-schema.org/draft/2020-12/vocab/meta-data",
            "https://json-schema.org/draft/2020-12/vocab/content",
            "https://spec.openapis.org/oas/3.1/vocab/base"
          )

          registry.add_format("int32", Skooma::Validators::Int32)
          registry.add_format("int64", Skooma::Validators::Int64)
          registry.add_format("float", Skooma::Validators::Float)
          registry.add_format("double", Skooma::Validators::Double)
        end
      end
    end
  end
end
