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

  describe "GET /things" do
    subject { get("/bar/things") }

    it { is_expected.to conform_schema(200) }
  end

  describe "GET /things/first5" do
    context "with .json" do
      subject { get("/bar/things/first5.json") }

      it { is_expected.to conform_schema(200) }
    end

    context "without .json" do
      subject { get("/bar/things/first5") }

      it { is_expected.to conform_schema(200) }
    end
  end

  describe "GET /things/:id" do
    context "with valid params" do
      subject { get("/bar/things/1") }

      it { is_expected.to conform_schema(200) }
    end

    context "with valid params outside of the range" do
      subject { get("/bar/things/33") }

      it { is_expected.to conform_schema(200) }
    end
  end
end
