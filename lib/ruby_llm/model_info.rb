# frozen_string_literal: true

require 'time'

module RubyLLM
  # Information about an AI model's capabilities, pricing, and metadata.
  # Used by the Models registry to help developers choose the right model
  # for their needs.
  #
  # Example:
  #   model = RubyLLM.models.find('gpt-4')
  #   model.supports_vision?          # => true
  #   model.supports_functions?       # => true
  #   model.input_price_per_million   # => 30.0
  class ModelInfo
    # Represents the modalities (input/output types) of a model.
    class Modality
      attr_reader :input, :output

      def initialize(data)
        @input = data&.fetch(:input, nil)
        @output = data&.fetch(:output, nil)
      end

      def to_h
        { input: input, output: output }
      end
    end

    # Represents the capabilities of a model, such as function calling and structured output.
    class Capabilities
      attr_reader :function_calling, :structured_output, :batch

      def initialize(data)
        @function_calling = data&.fetch(:function_calling, nil)
        @structured_output = data&.fetch(:structured_output, nil)
        @batch = data&.fetch(:batch, nil)
      end

      def to_h
        {
          function_calling: function_calling,
          structured_output: structured_output,
          batch: batch
        }
      end
    end

    # Represents the pricing information for a model, including input and output costs.
    class TokenPricing
      attr_reader :input_per_million, :cached_input_per_million, :output_per_million

      def initialize(data)
        @input_per_million = data&.fetch(:input_per_million, nil)
        @cached_input_per_million = data&.fetch(:cached_input_per_million, nil)
        @output_per_million = data&.fetch(:output_per_million, nil)
      end

      def to_h
        {
          input_per_million: input_per_million,
          cached_input_per_million: cached_input_per_million,
          output_per_million: output_per_million
        }
      end
    end

    attr_reader :id, :display_name, :provider, :context_window, :max_output_tokens,
                :modalities, :embeddings_output, :capabilities, :pricing

    def initialize(data) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      @id = data&.fetch(:id)
      @display_name = data&.fetch(:display_name, nil)
      @provider = data&.fetch(:provider)
      @context_window = data&.fetch(:context_window, nil)
      @max_output_tokens = data&.fetch(:max_output_tokens, nil)
      @modalities = {
        text: Modality.new(data&.dig(:modalities, :text)),
        image: Modality.new(data&.dig(:modalities, :image)),
        audio: Modality.new(data&.dig(:modalities, :audio))
      }
      @embeddings_output = data&.fetch(:embeddings_output, nil)
      @capabilities = Capabilities.new(data&.fetch(:capabilities, nil))
      @pricing = {
        text_tokens: {
          standard: TokenPricing.new(data&.dig(:pricing, :text_tokens, :standard)),
          batch: TokenPricing.new(data&.dig(:pricing, :text_tokens, :batch))
        },
        embeddings: {
          standard: TokenPricing.new(data&.dig(:pricing, :embeddings, :standard)),
          batch: TokenPricing.new(data&.dig(:pricing, :embeddings, :batch))
        }
      }
    end

    def to_h # rubocop:disable Metrics/MethodLength
      {
        id: id,
        display_name: display_name,
        provider: provider,
        context_window: context_window,
        max_output_tokens: max_output_tokens,
        modalities: modalities.transform_values(&:to_h),
        embeddings_output: embeddings_output,
        capabilities: capabilities.to_h,
        pricing: {
          text_tokens: pricing[:text_tokens].transform_values(&:to_h),
          embeddings: pricing[:embeddings].transform_values(&:to_h)
        }
      }
    end

    # Rest of the methods remain unchanged as they don't access the data hash directly
    def max_tokens
      max_output_tokens
    end

    def type
      return 'embedding' if @embeddings_output
      return 'audio' if @modalities[:audio].output
      return 'chat' if @modalities[:text].input
      return 'image' if @modalities[:image].output

      'unknown'
    end

    def supports_vision?
      @modalities[:image].input
    end

    def supports_functions?
      @capabilities.function_calling
    end

    def supports_json_mode?
      @capabilities.structured_output
    end

    def input_price_per_million
      @pricing[:text_tokens][:standard].input_per_million
    end

    def output_price_per_million
      @pricing[:text_tokens][:standard].output_per_million
    end
  end
end
