# frozen_string_literal: true

module RubyLLM
  module Providers
    module Gemini
      # Models methods for the Gemini API integration
      module Models
        # Methods needed by Provider - must be public
        def models_url
          'models'
        end

        private

        def parse_list_models_response(response, slug)
          (response.body['models'] || []).map do |model_data|
            model_id = model_data['name'].gsub('models/', '')
            {
              id: model_id,
              provider: slug,
              display_name: model_data['displayName'], # Gemini provides this
              initial_metadata: { version: model_data['version'] }
            }
          end
        end
      end
    end
  end
end
