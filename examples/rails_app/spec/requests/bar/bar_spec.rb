require "rails_helper"

describe "Bar API", :bar_api, type: :request do
  describe "GET /bar" do
    subject { get "/bar" }

    it { is_expected.to conform_schema(200) }

    it "returns correct response" do
      subject
      expect(response.parsed_body).to eq({"foo" => "bar"})
    end
  end

  describe "POST /bar" do
    subject { post("/bar", params: body, as: :json) }

    let(:body) { {foo: "bar"} }

    it { is_expected.to conform_schema(201) }

    context "with invalid params" do
      let(:body) { {foo: "baz"} }

      it { is_expected.to conform_response_schema(400) }
    end
  end
end
