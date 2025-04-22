# frozen_string_literal: true

module RubyLLM
  module Providers
    module Bedrock
      # Models methods for the AWS Bedrock API implementation
      module Models
        def models_url
          'foundation-models'
        end

        def list_models(connection:)
          config = connection.config
          mgmt_api_base = "https://bedrock.#{config.bedrock_region}.amazonaws.com"
          full_models_url = "#{mgmt_api_base}/#{models_url}"
          signature = sign_request(full_models_url, config:, method: :get)
          response = connection.get(full_models_url) do |req|
            req.headers.merge! signature.headers
          end

          parse_list_models_response(response, slug)
        end

        module_function

        def parse_list_models_response(response, slug) # rubocop:disable Metrics/MethodLength
          model_list = response.body['modelSummaries'] || []
          RubyLLM.logger.debug "Bedrock raw models list count: #{model_list.count}"
          model_list.filter { |model| model['modelId'].include?('claude') }
                    .map do |model_data|
            {
              id: model_data['modelId'],
              provider: slug,
              display_name: model_data['modelName'],
              initial_metadata: {
                provider_name: model_data['providerName'],
                inference_types_supported: model_data['inferenceTypesSupported'] || [],
                input_modalities: model_data['inputModalities'] || [],
                output_modalities: model_data['outputModalities'] || []
              }
            }
          end
        end
      end
    end
  end
end
