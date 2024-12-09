# frozen_string_literal: true

module Skooma
  class CoverageStore
    DEFAULT_FILE_PATH = File.join(Dir.pwd, "tmp", "skooma_coverage.json")

    attr_reader :file_path

    def initialize(file_path: DEFAULT_FILE_PATH)
      @file_path = file_path
      ensure_file_exists
    end

    def load_data
      with_lock("r") do |file|
        parse_data(file.read)
      end
    end

    def save_data(new_defined_paths, new_covered_paths)
      with_lock("r+") do |file|
        existing_data = parse_data(file.read)
        merged_data = merge_data(existing_data, new_defined_paths, new_covered_paths)

        file.rewind
        file.write(JSON.generate(merged_data))
        file.flush
        file.truncate(file.pos)
      end
    end

    private

    def ensure_file_exists
      FileUtils.mkdir_p(File.dirname(@file_path))
      FileUtils.touch(@file_path) unless File.exist?(@file_path)
    end

    def parse_data(content)
      return { defined_paths: Set.new, covered_paths: Set.new } if content.strip.empty?

      data = JSON.parse(content, symbolize_names: true)
      {
        defined_paths: Set.new(data[:defined_paths]),
        covered_paths: Set.new(data[:covered_paths])
      }
    end

    def merge_data(existing_data, new_defined_paths, new_covered_paths)
      {
        defined_paths: (existing_data[:defined_paths] | new_defined_paths).to_a,
        covered_paths: (existing_data[:covered_paths] | new_covered_paths).to_a
      }
    end

    def with_lock(mode)
      File.open(@file_path, mode) do |file|
        file.flock(File::LOCK_EX)
        yield(file)
      ensure
        file.flock(File::LOCK_UN)
      end
    end
  end
end
