# Copyright (c) 2024 OpenAI.cr Contributors
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

module OpenAI
    extend self

    COMPLETIONS_SUFFIX         = "/v1/completions"
    GPT4_32K_0613              = "gpt-4-32k-0613"
    GPT4_32K_0314              = "gpt-4-32k-0314"
    GPT4_32K                   = "gpt-4-32k"
    GPT4_0613                  = "gpt-4-0613"
    GPT4_0314                  = "gpt-4-0314"
    GPT4_TURBO                 = "gpt-4-turbo"
    GPT4_TURBO_20240409        = "gpt-4-turbo-2024-04-09"
    GPT4_TURBO_0125            = "gpt-4-0125-preview"
    GPT4_TURBO_1106            = "gpt-4-1106-preview"
    GPT4_TURBO_PREVIEW         = "gpt-4-turbo-preview"
    GPT4_VISION_PREVIEW        = "gpt-4-vision-preview"
    GPT4                       = "gpt-4"
    GPT3DOT5_TURBO_0125        = "gpt-3.5-turbo-0125"
    GPT3DOT5_TURBO_1106        = "gpt-3.5-turbo-1106"
    GPT3DOT5_TURBO_0613        = "gpt-3.5-turbo-0613"
    GPT3DOT5_TURBO_0301        = "gpt-3.5-turbo-0301"
    GPT3DOT5_TURBO_16K         = "gpt-3.5-turbo-16k"
    GPT3DOT5_TURBO_16K_0613    = "gpt-3.5-turbo-16k-0613"
    GPT3DOT5_TURBO             = "gpt-3.5-turbo"
    GPT3DOT5_TURBO_INSTRUCT    = "gpt-3.5-turbo-instruct"
    GPT3_DAVINCI_INSTRUCT_BETA = "davinci-instruct-beta"
    GPT3_DAVINCI               = "davinci"
    GPT3_DAVINCI_002           = "davinci-002"
    GPT3_CURIE                 = "curie"
    GPT3_CURIE_002             = "curie-002"
    GPT3_ADA                   = "ada"
    GPT3_ADA_002               = "ada-002"
    GPT3_BABBAGE               = "babbage"
    GPT3_BABBAGE_002           = "babbage-002"

	CODEX_CODE_DAVINCI_002     = "code-davinci-002"
	CODEX_CODE_CUSHMAN_001     = "code-cushman-001"
	CODEX_CODE_DAVINCI_001     = "code-davinci-001"

    DISABLED_MODELS_FOR_ENDPOINTS = {
        COMPLETIONS_SUFFIX => {
            GPT3DOT5_TURBO          => true,
            GPT3DOT5_TURBO_0301     => true,
            GPT3DOT5_TURBO_0613     => true,
            GPT3DOT5_TURBO_1106     => true,
            GPT3DOT5_TURBO_0125     => true,
            GPT3DOT5_TURBO_16K      => true,
            GPT3DOT5_TURBO_16K_0613 => true,
            GPT4                    => true,
            GPT4_TURBO_PREVIEW      => true,
            GPT4_VISION_PREVIEW     => true,
            GPT4_TURBO_1106         => true,
            GPT4_TURBO_0125         => true,
            GPT4_TURBO              => true,
            GPT4_TURBO_20240409     => true,
            GPT4_0314               => true,
            GPT4_0613               => true,
            GPT4_32K                => true,
            GPT4_32K_0314           => true,
            GPT4_32K_0613           => true,
        },
        CHAT_COMPLETIONS_SUFFIX => {
            CODEX_CODE_DAVINCI_002     => true,
            CODEX_CODE_CUSHMAN_001     => true,
            CODEX_CODE_DAVINCI_001     => true,
            GPT3_DAVINCI_INSTRUCT_BETA => true,
            GPT3_DAVINCI               => true,
            GPT3_DAVINCI_INSTRUCT_BETA => true,
            GPT3_CURIE                 => true,
            GPT3_ADA                   => true,
            GPT3_BABBAGE               => true,
        }
    }

    def endpoint_supports_model(endpoint : String, model : String) : Bool
        return !DISABLED_MODELS_FOR_ENDPOINTS.fetch(endpoint, Hash(String, Bool).new).fetch(model, false)
    end

    record(
        CompletionRequest,
        model : String,
        prompt : String | Array(String) | Nil = nil,
        suffix : String? = nil,
        max_tokens : Int32? = nil,
        temperature : Float32? = nil,
        top_p : Float32? = nil,
        n : Int32? = nil,
        stream : Bool? = nil,
        log_probs : Int32? = nil,
        echo : Bool? = nil,
        stop : Array(String)? = nil,
        presence_penalty : Float32? = nil,
        frequency_penalty : Float32? = nil,
        best_of : Int32? = nil,
        logit_bias : Hash(String, Int32)? = nil,
        user : String? = nil,
    ) do
        include JSON::Serializable
    end

    record(
        LogProbResult,
        tokens : Array(String),
        token_lobprobs : Array(Float32),
        top_logprobs : Array(Hash(String, Float32)),
        text_offset : Array(Int32),
    ) do
        include JSON::Serializable
    end

    record(
        CompletionChoice,
        text : String,
        index : Int32,
        finish_reason : String,
        logprobs : LogProbResult?,
    ) do
        include JSON::Serializable
    end

    record(
        CompletionResponse,
        id : String,
        object : String,
        created : Int64,
        model : String,
        choices : Array(CompletionChoice),
        usage : Usage,
    ) do
        include JSON::Serializable
    end

    class Client
        # Given a prompt, the model will return one or more 
        # predicted completions along with the probabilities of 
        # alternative tokens at each position. 
        # Most developer should use our Chat Completions API 
        # to leverage our best and newest models.
        #
        # ## Arguments
        #
        # * request : `OpenAI::CompletionRequest` - Request body to create a completion
        #
        # ## Examples
        #
        # ```
        # client = OpenAI::Client.new ENV["OPENAI_API_KEY"]
        #
        # completion_request = OpenAI::CompletionRequest.new(
        #   prompt: "Say this is a test",
        #   model: OpenAI::GPT3DOT5_TURBO_INSTRUCT
        # )
        #
        # puts client.completion(completion_request)
        # 
        # ```    
        @[Deprecated("Use `#chat_completion` instead")]
        def completion(request : CompletionRequest) : CompletionResponse
            make_request(COMPLETIONS_SUFFIX, request, CompletionResponse)
        end
    end
end