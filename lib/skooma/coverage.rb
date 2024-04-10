module Skooma
  class NoopCoverage
    def track_request(*)
    end

    def report
    end
  end

  class Coverage
    class SimpleReport
      def initialize(coverage)
        @coverage = coverage
      end

      attr_reader :coverage

      def report
        puts <<~MSG
          OpenAPI schema #{URI.parse(coverage.schema.uri.to_s).path} coverage report: #{coverage.covered_paths.count} / #{coverage.defined_paths.count} operations (#{coverage.covered_percent.round(2)}%) covered.
          #{coverage.uncovered_paths.empty? ? "All paths are covered!" : "Uncovered paths:"}
          #{coverage.uncovered_paths.map { |method, path, status| "#{method.upcase} #{path} #{status}" }.join("\n")}
        MSG
      end
    end

    def self.new(schema, mode: nil, format: nil)
      case mode
      when nil, false
        NoopCoverage.new
      when :report, :strict
        super
      else
        raise ArgumentError, "Invalid coverage: #{mode}, expected :report, :strict, or false"
      end
    end

    attr_reader :mode, :format, :defined_paths, :covered_paths, :schema

    def initialize(schema, mode:, format:)
      @schema = schema
      @mode = mode
      @format = format || SimpleReport
      @defined_paths = find_defined_paths(schema)
      @covered_paths = Set.new
    end

    def track_request(result)
      operation = [nil, nil, nil]
      result.collect_annotations(result.instance, keys: %w[paths responses]) do |node|
        case node.key
        when "paths"
          operation[0] = node.annotation["method"]
          operation[1] = node.annotation["current_path"]
        when "responses"
          operation[2] = node.annotation
        end
      end
      covered_paths << operation
    end

    def uncovered_paths
      defined_paths - covered_paths
    end

    def covered_percent
      covered_paths.count * 100.0 / defined_paths.count
    end

    def report
      format.new(self).report
      exit 1 if mode == :strict && uncovered_paths.any?
    end

    private

    def find_defined_paths(schema)
      Set.new.tap do |paths|
        schema["paths"].each do |path, path_item|
          resolved_path_item = (path_item.key?("$ref") ? path_item.resolve_ref(path_item["$ref"]) : path_item)
          resolved_path_item.slice("get", "post", "put", "patch", "delete", "options", "head", "trace").each do |method, operation|
            operation["responses"]&.each do |code, _|
              paths << [method, path, code]
            end
          end
        end
      end
    end
  end
end
