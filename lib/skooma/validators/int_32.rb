# frozen_string_literal: true
module Skooma
  module Validators
    class Int32 < JSONSkooma::Validators::Base
      def self.assert?(instance)
        instance.type == "number" && instance == instance.to_i
      end

      def call(instance)
        return if instance.value.bit_length <= 32

        raise JSONSkooma::Validators::FormatError, "must be a valid int32"
      end
    end
  end
end
