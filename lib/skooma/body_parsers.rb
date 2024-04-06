# frozen_string_literal: true

module Skooma
  module BodyParsers
    class << self
      DEFAULT_PARSER = ->(body, **_options) { body }

      def [](media_type)
        parsers[media_type.to_s.strip.downcase] || DEFAULT_PARSER
      end

      attr_accessor :parsers

      def register(*media_types, parser)
        media_types.each do |media_type|
          parsers[media_type.to_s.strip.downcase] = parser
        end
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
