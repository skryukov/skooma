# frozen_string_literal: true
module Skooma
  module Validators
    class Float < JSONSkooma::Validators::Base
      self.instance_types = "number"

      def call(instance)
        return if instance.value.is_a?(::Float)

        raise JSONSkooma::Validators::FormatError, "must be a valid float"
      end
    end
  end
end
