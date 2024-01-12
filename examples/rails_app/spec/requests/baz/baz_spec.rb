require "rails_helper"

describe "Baz API", :baz_api, type: :request do
  describe "GET prefixed /baz" do
    subject { get "/baz" }

    it { is_expected.to conform_schema(200) }

    it "returns correct response" do
      subject
      expect(response.parsed_body).to eq({"foo" => "baz"})
    end
  end

  describe "POST prefixed /baz" do
    subject { post("/baz", params: body, as: :json) }

    let(:body) { {foo: "baz"} }

    it { is_expected.to conform_schema(201) }

    context "with invalid params" do
      let(:body) { {foo: "bar"} }

      it { is_expected.to conform_response_schema(400) }
    end
  end
end
