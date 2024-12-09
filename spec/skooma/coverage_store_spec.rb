# frozen_string_literal: true

require "tmpdir"

RSpec.describe Skooma::CoverageStore do
  let(:temporary_dir) { Dir.mktmpdir }

  let(:temporary_file_path) { File.join(temporary_dir, "skooma_coverage.json") }

  subject(:coverage_store) { described_class.new(file_path: temporary_file_path) }

  after do
    FileUtils.remove_entry(temporary_dir) if Dir.exist?(temporary_dir)
  end

  describe "#initialize" do
    context "when the coverage file does not exist" do
      it "creates the coverage directory and file" do
        expect(File).not_to exist(temporary_file_path)

        coverage_store

        expect(File).to exist(temporary_file_path)
        expect(File.size?(temporary_file_path)).to be_nil # File is empty
      end
    end

    context "when the coverage file already exists" do
      before do
        FileUtils.mkdir_p(File.dirname(temporary_file_path))
        File.write(temporary_file_path, '{"defined_paths": ["get /users 200"], "covered_paths": ["get /users 200"]}')
      end

      it "does not alter the existing file" do
        expect(File).to exist(temporary_file_path)
        initial_content = File.read(temporary_file_path)

        coverage_store

        expect(File.read(temporary_file_path)).to eq(initial_content)
      end
    end
  end

  describe "#load_data" do
    context "when the coverage file is empty" do
      before do
        File.write(temporary_file_path, "")
      end

      it "returns empty defined_paths and covered_paths" do
        data = coverage_store.load_data
        expect(data[:defined_paths]).to be_a(Set)
        expect(data[:covered_paths]).to be_a(Set)
        expect(data[:defined_paths]).to be_empty
        expect(data[:covered_paths]).to be_empty
      end
    end

    context "when the coverage file has valid JSON data" do
      let(:defined_paths) { Set.new([["get", "/users", "200"], ["post", "/users", "201"]]) }
      let(:covered_paths) { Set.new([["get", "/users", "200"]]) }

      let(:json_content) do
        {
          defined_paths: defined_paths.to_a,
          covered_paths: covered_paths.to_a
        }.to_json
      end

      before do
        File.write(temporary_file_path, json_content)
      end

      it "returns the correct defined_paths and covered_paths" do
        data = coverage_store.load_data
        expect(data[:defined_paths]).to eq(defined_paths)
        expect(data[:covered_paths]).to eq(covered_paths)
      end
    end

    context "when the coverage file has invalid JSON" do
      before do
        File.write(temporary_file_path, "invalid json")
      end

      it "raises a JSON::ParserError" do
        expect { coverage_store.load_data }.to raise_error(JSON::ParserError)
      end
    end
  end

  describe "#save_data" do
    context "when the coverage file is empty" do
      before do
        File.write(temporary_file_path, "")
      end

      let(:new_defined_paths) { Set.new([["get", "/users", "200"]]) }
      let(:new_covered_paths) { Set.new([["get", "/users", "200"]]) }

      it "writes the new defined_paths and covered_paths to the file" do
        coverage_store.save_data(new_defined_paths, new_covered_paths)

        data = JSON.parse(File.read(temporary_file_path), symbolize_names: true)

        expect(Set.new(data[:defined_paths])).to eq(new_defined_paths)
        expect(Set.new(data[:covered_paths])).to eq(new_covered_paths)
      end
    end

    context "when the coverage file has existing data" do
      let(:existing_defined_paths) { Set.new([["get", "/users", "200"]]) }
      let(:existing_covered_paths) { Set.new([["get", "/users", "200"]]) }

      let(:existing_json_content) do
        {
          defined_paths: existing_defined_paths.to_a,
          covered_paths: existing_covered_paths.to_a
        }.to_json
      end

      before do
        File.write(temporary_file_path, existing_json_content)
      end

      let(:new_defined_paths) { Set.new([["post", "/users", "201"]]) }
      let(:new_covered_paths) { Set.new([["post", "/users", "201"]]) }

      it "merges the new defined_paths and covered_paths with existing ones" do
        coverage_store.save_data(new_defined_paths, new_covered_paths)

        data = JSON.parse(File.read(temporary_file_path), symbolize_names: true)

        expected_defined_paths = existing_defined_paths.merge(new_defined_paths)
        expected_covered_paths = existing_covered_paths.merge(new_covered_paths)

        expect(Set.new(data[:defined_paths])).to eq(expected_defined_paths)
        expect(Set.new(data[:covered_paths])).to eq(expected_covered_paths)
      end

      it "does not duplicate existing paths" do
        coverage_store.save_data(existing_defined_paths, existing_covered_paths)

        data = JSON.parse(File.read(temporary_file_path), symbolize_names: true)

        expect(Set.new(data[:defined_paths])).to eq(existing_defined_paths)
        expect(Set.new(data[:covered_paths])).to eq(existing_covered_paths)
      end
    end

    context "when merging overlapping defined_paths and covered_paths" do
      let(:existing_defined_paths) { Set.new([["get", "/users", "200"]]) }
      let(:existing_covered_paths) { Set.new([["get", "/users", "200"]]) }

      let(:existing_json_content) do
        {
          defined_paths: existing_defined_paths.to_a,
          covered_paths: existing_covered_paths.to_a
        }.to_json
      end

      before do
        File.write(temporary_file_path, existing_json_content)
      end

      let(:new_defined_paths) { Set.new([["get", "/users", "200"], ["post", "/users", "201"]]) }
      let(:new_covered_paths) { Set.new([["get", "/users", "200"], ["post", "/users", "201"]]) }

      it "merges without duplicating existing entries" do
        coverage_store.save_data(new_defined_paths, new_covered_paths)

        data = JSON.parse(File.read(temporary_file_path), symbolize_names: true)

        expected_defined_paths = existing_defined_paths.merge(new_defined_paths)
        expected_covered_paths = existing_covered_paths.merge(new_covered_paths)

        expect(Set.new(data[:defined_paths])).to eq(expected_defined_paths)
        expect(Set.new(data[:covered_paths])).to eq(expected_covered_paths)
      end
    end
  end
end
