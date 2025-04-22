# frozen_string_literal: true

module RubyLLM
  module Providers
    module Anthropic
      # Models methods of the Anthropic API integration
      module Models
        private

        def models_url
          '/v1/models'
        end

        def parse_list_models_response(response, slug)
          model_list = response.body['data'] || []
          model_list.map do |model_data|
            created_time = model_data['created_at'] ? Time.parse(model_data['created_at']) : nil
            {
              id: model_data['id'],
              provider: slug,
              display_name: model_data['display_name'],
              created_at: created_time
            }
          end
        end

        def extract_model_id(data)
          data.dig('message', 'model')
        end

        def extract_input_tokens(data)
          data.dig('message', 'usage', 'input_tokens')
        end

        def extract_output_tokens(data)
          data.dig('message', 'usage', 'output_tokens') || data.dig('usage', 'output_tokens')
        end
      end
    end
  end
end
