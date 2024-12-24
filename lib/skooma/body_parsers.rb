# frozen_string_literal: true

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
  end
end
