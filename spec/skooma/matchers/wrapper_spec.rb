# frozen_string_literal: true

require "tmpdir"

# Minimal store implementing the CoverageStore interface in memory.
class MemoryCoverageStore
  attr_reader :defined_paths, :covered_paths

  def initialize
    @defined_paths = Set.new
    @covered_paths = Set.new
  end

  def load_data
    {defined_paths: Set.new(@defined_paths), covered_paths: Set.new(@covered_paths)}
  end

  def save_data(new_defined_paths, new_covered_paths)
    @defined_paths |= new_defined_paths
    @covered_paths |= new_covered_paths
  end

  def clear
    @defined_paths.clear
    @covered_paths.clear
  end
end

RSpec.describe Skooma::Matchers::Wrapper do
  def write_openapi_doc(dir)
    path = File.join(dir, "openapi.yaml")
    File.write(path, <<~YAML)
      openapi: 3.1.0
      info: {title: t, version: "1"}
      paths:
        /health:
          get:
            responses:
              '200':
                description: OK
    YAML
    path
  end

  it "uses the coverage store passed via coverage_store:" do
    Dir.mktmpdir do |dir|
      store = MemoryCoverageStore.new
      wrapper = described_class.new(
        Module.new, write_openapi_doc(dir),
        base_uri: "https://wrapper-spec.test/custom/",
        coverage: :report, coverage_store: store
      )

      expect(wrapper.coverage.storage).to be(store)
      expect(store.defined_paths).to include(["get", "/health", "200"])
    end
  end

  it "defaults to a file-backed CoverageStore" do
    Dir.mktmpdir do |dir|
      wrapper = described_class.new(
        Module.new, write_openapi_doc(dir),
        base_uri: "https://wrapper-spec.test/default/",
        coverage: :report
      )

      storage = wrapper.coverage.storage
      expect(storage).to be_a(Skooma::CoverageStore)
      expect(storage.file_path).to include("skooma_coverage_")
      storage.clear
    end
  end
end
