# frozen_string_literal: true

require "rack/utils"
require "rack/multipart"

module Skooma
  module BodyParsers
    class << self
      DEFAULT_PARSER = ->(body, **_options) { body }

      def [](media_type)
        key = normalize_media_type(media_type)
        parsers[key] ||
          find_suffix_parser(key) ||
          find_fallback_parser(key) ||
          DEFAULT_PARSER
      end

      attr_accessor :parsers

      def register(*media_types, parser)
        media_types.each do |media_type|
          parsers[normalize_media_type(media_type)] = parser
        end
      end

      private

      def normalize_media_type(media_type)
        media_type.to_s.strip.downcase
      end

      def find_suffix_parser(media_type)
        return unless media_type.include?("+")

        suffix = media_type.split("+").last
        parsers["application/#{suffix}"]
      end

      def find_fallback_parser(media_type)
        type = media_type.split("/").first
        parsers["#{type}/*"] || parsers["*/*"]
      end
    end
    self.parsers = {}

    module JSONParser
      def self.call(body, **_options)
        JSON.parse(body)
      rescue JSON::ParserError
        body
      end
    end
    register "application/json", JSONParser

    module FormURLEncodedParser
      def self.call(body, **_options)
        Rack::Utils.parse_nested_query(body)
      # The set of parse error classes differs across Rack 2/3; a malformed
      # body falls back to the raw string so schema validation rejects it.
      rescue
        body
      end
    end
    register "application/x-www-form-urlencoded", FormURLEncodedParser

    # Parses multipart bodies with Rack's multipart parser (the boundary is
    # taken from the request's own Content-Type header). File parts are
    # replaced by their content read as a binary string, so they validate
    # against `type: string` / `format: binary` schemas.
    module MultipartParser
      def self.call(body, headers: nil, **_options)
        content_type = headers && headers["Content-Type"]&.value
        return body if content_type.nil? || body.nil?

        input = StringIO.new(body.to_s.dup.force_encoding(Encoding::BINARY))
        params = Rack::Multipart.parse_multipart(
          "CONTENT_TYPE" => content_type,
          "CONTENT_LENGTH" => input.size.to_s,
          "rack.input" => input
        )
        return body if params.nil?

        simplify(params)
      # Rack 2/3 raise different errors on malformed multipart (Multipart::Error,
      # EOFError, ...); fall back to the raw string so validation rejects it.
      rescue
        body
      end

      def self.simplify(value)
        case value
        when Hash
          if value.key?(:tempfile)
            value[:tempfile].read.force_encoding(Encoding::BINARY)
          else
            value.transform_values { |member| simplify(member) }
          end
        when Array
          value.map { |member| simplify(member) }
        else
          value
        end
      end
      private_class_method :simplify
    end
    register "multipart/form-data", MultipartParser
  end
end
