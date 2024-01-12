require "rails_helper"

describe "OpenAPI documents", type: :request do
  describe "Bar API", :bar_api do
    subject(:schema) { skooma_openapi_schema }

    it { is_expected.to be_valid_document }
  end

  describe "Baz API", :baz_api do
    subject(:schema) { skooma_openapi_schema }

    it { is_expected.to be_valid_document }
  end
end
