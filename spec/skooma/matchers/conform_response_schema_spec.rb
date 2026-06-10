# frozen_string_literal: true

RSpec.describe Skooma::Matchers::ConformResponseSchema do
  let(:result) { instance_double(JSONSkooma::Result, valid?: true) }
  let(:schema) { instance_double(Skooma::Objects::OpenAPI, evaluate: result) }
  let(:coverage) { instance_double(Skooma::Coverage, track_request: nil) }
  let(:skooma) { instance_double(Skooma::Matchers::Wrapper, schema: schema, coverage: coverage) }
  let(:mapped_response) { {"response" => {"status" => 201}} }

  subject(:matcher) { described_class.new(skooma, mapped_response, expected) }

  describe "#matches?" do
    context "with an integer matching the response status" do
      let(:expected) { 201 }

      it { expect(matcher.matches?).to be true }
    end

    context "with an integer not matching the response status" do
      let(:expected) { 200 }

      it { expect(matcher.matches?).to be false }
    end

    context "with a symbol matching the response status" do
      let(:expected) { :created }

      it { expect(matcher.matches?).to be true }
    end

    context "with a symbol not matching the response status" do
      let(:expected) { :ok }

      it { expect(matcher.matches?).to be false }
    end

    context "when the status matches but the schema validation fails" do
      let(:expected) { 201 }
      let(:result) { instance_double(JSONSkooma::Result, valid?: false) }

      it { expect(matcher.matches?).to be false }
    end
  end

  describe "#initialize" do
    context "with neither a symbol nor an integer" do
      let(:expected) { "201" }

      it "raises ArgumentError" do
        expect { matcher }.to raise_error(ArgumentError, /Expected symbol or number/)
      end
    end

    context "with an unknown symbol" do
      let(:expected) { :nonsense }

      it "raises KeyError" do
        expect { matcher }.to raise_error(KeyError)
      end
    end
  end

  describe "#failure_message" do
    let(:expected) { :ok }

    it "renders the supplied expected value" do
      matcher.matches?
      expect(matcher.failure_message).to eq("Expected ok status code, but got 201")
    end
  end
end
