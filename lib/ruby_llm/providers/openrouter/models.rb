# frozen_string_literal: true

# lib/ruby_llm/providers/openrouter/models.rb
module RubyLLM
  module Providers
    module OpenRouter
      module Models # rubocop:disable Style/Documentation
        module_function

        def models_url
          'models'
        end

        def parse_list_models_response(response, slug)
          model_list = response.body['data'] || []
          model_list.map do |model_data|
            map_openrouter_to_model_info_args(model_data, slug)
          end
        end

        private

        def map_openrouter_to_model_info_args(or_data, slug) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          or_data_sym = RubyLLM::Utils.symbolize_keys_deep(or_data)
          data = {
            id: or_data_sym[:id],
            display_name: or_data_sym[:name],
            provider: slug,
            context_window: or_data_sym[:context_length],
            max_output_tokens: or_data_sym.dig(:top_provider, :max_completion_tokens),
            embeddings_output: nil,
            source_data: or_data_sym
          }
          arch = or_data_sym[:architecture] || {}
          input_modalities = Set.new(arch[:input_modalities] || [])
          output_modalities = Set.new(arch[:output_modalities] || [])
          data[:modalities] = {
            text: { input: true, output: output_modalities.include?('text') },
            image: { input: input_modalities.include?('image'), output: output_modalities.include?('image') },
            audio: { input: input_modalities.include?('audio'), output: output_modalities.include?('audio') }
          }
          data[:capabilities] = {
            function_calling: true, # Assume true for modern models via OpenRouter
            structured_output: true, # Assume true for modern models via OpenRouter
            batch: false # Assume false unless specified otherwise
          }
          pricing = or_data_sym[:pricing] || {}
          input_price = pricing[:prompt]&.to_f
          output_price = pricing[:completion]&.to_f
          data[:pricing] = {
            text_tokens: {
              standard: {
                input_per_million: input_price ? input_price * 1_000_000 : nil,
                cached_input_per_million: nil, # Not provided by OpenRouter directly
                output_per_million: output_price ? output_price * 1_000_000 : nil
              },
              batch: {} # No batch pricing info from OpenRouter
            },
            embeddings: {
              standard: {}, # No embedding pricing info from OpenRouter
              batch: {}
            }
          }
          data
        end
      end
    end
  end
end
