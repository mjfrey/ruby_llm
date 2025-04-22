# frozen_string_literal: true

module RubyLLM
  module Providers
    module OpenAI
      # Models methods of the OpenAI API integration
      module Models
        module_function

        def models_url
          'models'
        end

        def parse_list_models_response(response, slug)
          (response.body['data'] || []).map do |model_data|
            {
              id: model_data['id'],
              provider: slug,
              created_at: model_data['created'] ? Time.at(model_data['created']) : nil,
              initial_metadata: { owned_by: model_data['owned_by'] }
            }
          end
        end

        def normalize_temperature(temperature, model_id)
          if model_id.match?(/^o\d/)
            RubyLLM.logger.debug "Model #{model_id} requires temperature=1.0, ignoring provided value"
            1.0
          else
            temperature
          end
        end
      end
    end
  end
end
