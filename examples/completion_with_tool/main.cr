require "../../src/openai"

client = OpenAI::Client.new ENV["OPENAI_API_KEY"]

params = JsonSchema::Definition.new(
    type: JsonSchema::DataType::Object,
    properties: {
        "location" => JsonSchema::Definition.new(
            type: JsonSchema::DataType::String,
            description: "The city and state"
        ),
        "unit" => JsonSchema::Definition.new(
            type: JsonSchema::DataType::String,
            members: ["celsius", "fahrenheit"]
        )
    },
    required: ["location"],
)

f = OpenAI::FunctionDefinition.new(
    name: "get_current_weather",
    description: "Get the weather in a given location",
    parameters: JSON.parse params.to_json
)

t = OpenAI::Tool.new(
    type: OpenAI::ToolType::Function,
    function: f
)

puts "Asking: What is the weather in Boston today?"

# A question that needs the tool call
dialogue = [
    OpenAI::ChatCompletionMessage.new(
        role: OpenAI::ChatMessageRole::User,
        content: "What is the weather in boston today?"
    )
]

response = client.chat_completion(
    OpenAI::ChatCompletionRequest.new(
        model: OpenAI::GPT4_TURBO_PREVIEW,
        messages: dialogue,
        tools: [t],
    )
)

# Simulate a tool call response
msg = response.choices[0].message
dialogue << msg

dialogue << OpenAI::ChatCompletionMessage.new(
    role: OpenAI::ChatMessageRole::Tool,
    content: "Sunny and 80 degrees",
    name: msg.tool_calls.not_nil![0].function.name,
    tool_call_id: msg.tool_calls.not_nil![0].id
)

# Asking for a response, with the tool call added to context
response = client.chat_completion(OpenAI::ChatCompletionRequest.new(model: OpenAI::GPT4_TURBO_PREVIEW, messages: dialogue, tools: [t]))

puts response.choices[0].message.content