# frozen_string_literal: true
module Skooma
  module Validators
    class Int64 < JSONSkooma::Validators::Base
      def self.assert?(instance)
        instance.type == "number" && instance == instance.to_i
      end

      def call(instance)
        return if instance.value.bit_length <= 64

        raise JSONSkooma::Validators::FormatError, "must be a valid int64"
      end
    end
  end
end
