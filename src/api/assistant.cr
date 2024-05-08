module OpenAI
    ASSISTANT_API_PATH = "/v1/assistants"
    ASSISTANT_FILES_API_PATH = "/v1/files"
    OPENAI_ASSISTANTS_V1 = "assistants=v1"

    enum AssistantToolType
        CodeIntepreter
        Retrieval
        Function
    end

    record(
        AssistantTool,
        type : AssistantToolType,
        function : FunctionDefinition? = nil
    ) do
        include JSON::Serializable
    end

    record(
        Assistant,
        id : String,
        object : String,
        created_at : Int64,
        model : String,
        tools : Array(AssistantTool),
        name : String? = nil,
        description : String? = nil,
        instructions : String? = nil,
        file_ids : Array(String)? = nil,
        metadata : Hash(String, JSON::Any)? = nil,
    ) do
        include JSON::Serializable
    end

    record(
        AssistantRequest,
        model : String,
        name : String? = nil,
        description : String? = nil,
        instructions : String? = nil,
        tools : Array(AssistantTool)? = nil,
        file_ids : Array(String)? = nil,
        metadata : Hash(String, JSON::Any)? = nil,
    ) do
        include JSON::Serializable
    end

    record(
        AssistantsList,
        data : Array(Assistant),
        has_more : Bool,
        last_id : String? = nil,
        first_id : String? = nil,
    ) do
        include JSON::Serializable
    end

    record(
        AssistantDeleteResponse,
        id : String,
        object : String,
        deleted : Bool,
    ) do
        include JSON::Serializable
    end

    record(
        AssistantFile,
        id : String,
        object : String,
        created_at : Int64,
        assistant_id : String,
    ) do
        include JSON::Serializable
    end

    record(
        AssistantFileRequest,
        file_id : String,
    ) do
        include JSON::Serializable
    end

    record(
        AssistantFilesList,
        data : Array(AssistantFile)
    ) do
        include JSON::Serializable
    end

    class Client
        # Create an assistant with a model and instructions.
        #
        # ## Arguments
        #
        # * request : `OpenAI::AssistantRequest` - Request body to create an assistant
        #
        # ## Examples
        #
        # ```
        # client = OpenAI::Client.new ENV["OPENAI_API_KEY"]
        #
        # assistant = OpenAI::AssistantRequest.new(
        #   name: "Spanish tutor",
        #   instructions: "You are a personal spanish tutor, teach everyone spanish!",
        #   model: OpenAI::GPT4_TURBO
        # )
        #
        # response = client.create_assistant(assistant)
        # 
        # ```        
        def create_assistant(request : AssistantRequest) : Assistant
            make_request(ASSISTANT_API_PATH, request, Assistant) do |headers|
                headers.add("OpenAI-Beta", "assistants=#{@config.assistant_version}")
            end
        end

        # Retrieve an already created assistant
        #
        # ## Arguments
        #
        # * assistant_id : `String` - ID of created assistant
        #
        # ## Examples
        #
        # ```
        # client = OpenAI::Client.new ENV["OPENAI_API_KEY"]
        #
        # response = client.retrieve_assistant(assistant_id)
        # 
        # ``` 
        def retrieve_assistant(assistant_id : String) : Assistant
            make_get_request("#{ASSISTANT_API_PATH}/#{assistant_id}", Assistant) do |headers|
                headers.add("OpenAI-Beta", "assistants=#{@config.assistant_version}")
            end
        end

        # Modify an existing assistant
        #
        # ## Arguments
        #
        # * assistant_id : `String` - Existing assistant id
        # * request : `OpenAI::AssistantRequest` - Request body to update existing assistant
        #
        # ## Examples
        #
        # ```
        # client = OpenAI::Client.new ENV["OPENAI_API_KEY"]
        #
        # assistant = OpenAI::AssistantRequest.new(
        #   name: "Spanish tutor",
        #   instructions: "You are a personal spanish tutor, teach everyone spanish!",
        #   model: OpenAI::GPT4_TURBO
        # )
        #
        # response = client.modify_assistant(assistant_id, assistant)
        # 
        # ``` 
        def modify_assistant(assistant_id : String, request : AssistantRequest) : Assistant
            make_request("#{ASSISTANT_API_PATH}/#{assistant_id}", request, Assistant) do |headers|
            headers.add("OpenAI-Beta", "assistants=#{@config.assistant_version}")
            end
        end

        # List assistants
        #
        # ## Arguments
        #
        # * limit : `Int32 | Nil` - How many assistants to return
        # * order : `String | Nil` - asc or desc
        # * after : `String | Nil` - assistant_id to return after
        # * before : `String | Nil` - assistant_id to return before
        #
        # ## Examples
        #
        # ```
        # client = OpenAI::Client.new ENV["OPENAI_API_KEY"]
        #
        # response = client.retrieve_assistant(assistant_id)
        # 
        # ``` 
        def list_assistants(limit : Int32? = nil, order : String? = nil, after : String? = nil, before : String? = nil) : AssistantsList
            params = URI::Params.build do |form|
                form.add("limit", limit.to_s) unless limit.nil?
                form.add("order", order) unless order.nil?
                form.add("after", after) unless after.nil?
                form.add("before", before) unless before.nil?
            end

            params = "?#{params}" unless params.size == 0
            make_get_request("#{ASSISTANT_API_PATH}#{params}", AssistantsList) do |headers|
                headers.add("OpenAI-Beta", "assistants=#{@config.assistant_version}")
            end
        end
    end
end