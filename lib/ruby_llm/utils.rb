# frozen_string_literal: true

module RubyLLM
  # Utility methods for the RubyLLM library.
  module Utils
    module_function

    def symbolize_keys_deep(hash)
      hash.transform_keys(&:to_sym).transform_values do |v|
        v.is_a?(Hash) ? symbolize_keys_deep(v) : v
      end
    end
  end
end
