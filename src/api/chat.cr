# Copyright (c) 2024 OpenAI.cr Contributors
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT


module OpenAI
    CHAT_COMPLETIONS_SUFFIX = "/v1/chat/completions"

    # The role of the author of a message, used to track
    # context during a conversation with an LLM
    enum ChatMessageRole
        System
        User
        Assistant
        Tool
        Function
    end

    # Type of OpenAI tool to use, currently only `function`
    # is supported
    enum ToolType
        Function
    end

    # Optional format provided in a response.
    enum ResponseFormatType
        # If the model supports JSON mode, the response will be guaranteed
        # to be valid JSON if `JsonObject` is selected.
        # 
        # Compatible with GPT-4 Turbo and all GPT-3.5 Turbo models
        # newer than gpt-3.5-turbo-1106
        JsonObject
    end

    # The reason the model stopped generating tokens. This will be stop 
    # if the model hit a natural stop point or a provided stop sequence, 
    # length if the maximum number of tokens specified in the request was 
    # reached, content_filter if content was omitted due to a flag from
    # our content filters, tool_calls if the model called a tool,
    # or function_call (deprecated) if the model called a function.
    enum FinishReason
        # Hit if there is a natural stop or stop sequence
        Stop
        # Hit if the max number of tokens was reached
        Length
        # Hit if a function was called
        FunctionCall
        # Hit if a function was called
        ToolCalls
        # Hit if content was omitted due to content flags
        ContentFilter
        Null
    end

    # In an API call, you can describe functions and have the model
    # intelligently choose to output a JSON object containing
    # arguments to call one or many functions. The Chat Completions
    # API does not call the function; instead, the model generates
    # JSON that you can use to call the function in your code.
    record(
        Function,
        name : String,
        arguments : String,
    ) do
        include JSON::Serializable
    end

    # The response from the API dictating the functions and types
    # that were called as part of a function call
    record(
        ToolCall,
        id : String,
        type : String,
        function : Function,
    ) do
        include JSON::Serializable
    end

    @[Deprecated("Use `ToolCall` instead")]
    record(
        FunctionCall,
        arguments : String,
        name : String,
    ) do
        include JSON::Serializable
    end

    @[Deprecated("Use `Tool` instead")]
    record(
        FunctionDefinition,
        name : String,
        description : String? = nil,
        parameters : JSON::Any? = nil,
    ) do
        include JSON::Serializable
    end

    # Defines a function and type that can be used to generate `ToolCall`'s
    # in an API response
    record(
        Tool,
        type : ToolType,
        function : FunctionDefinition,
    ) do
        include JSON::Serializable
    end

    # Defines a tool that can be used in an API response
    record(
        ToolChoice,
        type : ToolType,
        function : FunctionDefinition? = nil,
    ) do
        include JSON::Serializable
    end

    # Specifies a response format from the API if supported
    # by the model
    record(
        ResponseFormat,
        type : ResponseFormatType
    ) do
        include JSON::Serializable
    end

    # A message used to generate a chat completion
    record(
        ChatCompletionMessage,
        content : String? = nil,
        role : ChatMessageRole? = nil,
        name : String? = nil,
        tool_calls : Array(ToolCall)? = nil,
        function_call : FunctionCall? = nil,
        tool_call_id : String? = nil,
    ) do
        include JSON::Serializable
    end

    # A message response from the API
    record(
        ChatCompletionChoice,
        index : Int32,
        message : ChatCompletionMessage,
        finish_reason
    ) do
        include JSON::Serializable
    end

    record(
        TopLogProbs,
        token : String,
        log_prob : Float64,
        bytes : Array(UInt8)? = nil,
    ) do
        include JSON::Serializable
    end

    record(
        LogProb,
        token : String,
        log_prob : Float64,
        top_log_probs : Array(TopLogProbs),
        bytes : Array(UInt8)? = nil,
    ) do
        include JSON::Serializable
    end

    record(
        LogProbs,
        content : Array(LogProb),
    ) do
        include JSON::Serializable
    end

    record(
        ChatCompletionRequest,
        messages : Array(ChatCompletionMessage),
        model : String,
        frequency_penalty : Float64? = nil,
        logit_bias : Hash(String, Int32)? = nil,
        logprobs : Bool? = nil,
        top_logprobs : Int32? = nil,
        max_tokens : Int32? = nil,
        n : Int32? = nil,
        presence_penalty : Int32? = nil,
        response_format : ResponseFormat? = nil,
        seed : Int32? = nil,
        stop : Array(String)? = nil,
        stream : Bool? = nil,
        temperature : Float64? = nil,
        top_p : Float32? = nil,
        tools : Array(Tool)? = nil,
        tool_choice : String | ToolChoice | Nil = nil,
        user : String? = nil,
        function_call : String | Function | Nil = nil,
        functions : Array(FunctionDefinition)? = nil,
    ) do
        include JSON::Serializable
    end

    record(
        ChatCompletionChoice,
        index : Int32,
        message : ChatCompletionMessage,
        finish_reason : FinishReason,
        log_probs : LogProbs? = nil
    ) do
        include JSON::Serializable
    end

    record(
        ChatCompletionResponse,
        id : String,
        object : String,
        created : Int64,
        model : String,
        choices : Array(ChatCompletionChoice),
        usage : Usage,
        system_fingerprint : String? = nil,
    ) do
        include JSON::Serializable
    end

    class Client
        # Given a list of messages comprising a conversation, 
        # the model will return a response.
        # 
        # ## Arguments
        #
        # * request : `OpenAI::ChatCompletionRequest` - Request body to create a completion
        #
        # ## Examples
        #
        # ```
        # client = OpenAI::Client.new ENV["OPENAI_API_KEY"]
        #
        # req = OpenAI::ChatCompletionRequest.new(
        #     model: OpenAI::GPT3DOT5_TURBO,
        #     messages: [
        #         OpenAI::ChatCompletionMessage.new(
        #             role: OpenAI::ChatMessageRole::User,
        #             content: "Hello!"
        #         )
        #     ]
        # )
        #
        # puts client.chat_completion(req)
        # 
        # ```  
        def chat_completion(request : ChatCompletionRequest) : ChatCompletionResponse
            make_request(CHAT_COMPLETIONS_SUFFIX, request, ChatCompletionResponse)
        end
    end
end