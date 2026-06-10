# frozen_string_literal: true

require "tmpdir"

RSpec.describe "External $ref coverage" do
  def fresh_coverage(schema)
    storage = Skooma::CoverageStore.new(
      file_path: File.join(Dir.mktmpdir, "coverage.json")
    )
    Skooma::Coverage.new(schema, mode: :report, storage: storage)
  end

  context "PathItem external $ref" do
    let(:schema) { load_external_refs_fixture("path_item") }
    let(:coverage) { fresh_coverage(schema) }

    it "enumerates responses defined in the external file" do
      expect(coverage.defined_paths).to include(["get", "/health", "200"])
    end

    it "marks the endpoint covered after a valid request is tracked" do
      result = schema.evaluate(
        "method" => "get",
        "path" => "/health",
        "request" => {"headers" => {"Content-Type" => "application/json"}},
        "response" => {"status" => 200, "headers" => {"Content-Type" => "application/json"}, "body" => '{"status": "ok"}'}
      )
      expect(result).to be_valid

      coverage.track_request(result)
      expect(coverage.covered_paths).to include(["get", "/health", "200"])
      expect(coverage.uncovered_paths).to be_empty
    end
  end

  context "external Response $ref (basic fixture)" do
    let(:schema) { load_external_refs_fixture("basic") }
    let(:coverage) { fresh_coverage(schema) }

    it "enumerates both inline and externally-referenced endpoint responses" do
      expect(coverage.defined_paths).to include(
        ["get", "/users", "200"],
        ["get", "/users/{id}", "200"]
      )
    end

    it "marks endpoints covered as requests are tracked" do
      result = schema.evaluate(
        "method" => "get",
        "path" => "/users",
        "request" => {"headers" => {"Content-Type" => "application/json"}},
        "response" => {"status" => 200, "headers" => {"Content-Type" => "application/json"}, "body" => '[{"id": 1, "name": "Alice"}]'}
      )
      expect(result).to be_valid
      coverage.track_request(result)

      expect(coverage.covered_paths).to include(["get", "/users", "200"])
      expect(coverage.uncovered_paths).to include(["get", "/users/{id}", "200"])
    end
  end
end
