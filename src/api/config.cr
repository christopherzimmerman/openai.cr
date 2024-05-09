# Copyright (c) 2024 OpenAI.cr Contributors
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

module OpenAI
  OPENAI_API_URL_V1            = "api.openai.com"
  DEFAULT_EMPTY_MESSAGES_LIMIT = 300_u32
  AZURE_API_PREFIX             = "openai"
  AZURE_DEPLOYMENTS_PREFIX     = "deployments"
  AZURE_API_KEY_HEADER         = "api-key"
  DEFAULT_ASSISTANT_VERSION    = "v1"

  enum ApiType
    OPENAI
    AZURE
    AZURE_AD
  end

  struct ClientConfig
    getter auth_token : String
    getter base_url : String
    getter org_id : String
    getter api_type : ApiType
    getter api_version : String
    getter assistant_version : String
    getter azure_model_mapper_func : Proc(String, String)
    getter empty_messages_limit : UInt32
    getter http_client : HTTP::Client

    def initialize(
      @auth_token : String,
      @base_url : String = OPENAI_API_URL_V1,
      @org_id : String = "",
      @api_type : ApiType = ApiType::OPENAI,
      @api_version : String = "",
      @assistant_version : String = DEFAULT_ASSISTANT_VERSION,
      @azure_model_mapper_func : Proc(String, String) = ->(model : String) { model },
      @empty_messages_limit : UInt32 = DEFAULT_EMPTY_MESSAGES_LIMIT
    )
      @http_client = HTTP::Client.new @base_url, tls: true
    end

    def self.azure(
      auth_token : String,
      base_url : String
    )
      new(
        auth_token,
        base_url,
        api_type: ApiType::AZURE,
        api_version: "2023-05-15",
        azure_model_mapper_func: ->(model : String) { model.gsub(/[.:]/, "") }
      )
    end

    def azure_deployment(model : String) : String
      @azure_model_mapper_func.call(model)
    end
  end
end
