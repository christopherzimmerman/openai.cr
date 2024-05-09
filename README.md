# openai

Client library for OpenAI.  Currently supports the OpenAI API with
support with Azure coming soon.  This library is community maintained,
and is primarily being maintained to be a strictly typed backend
for `Cascade`.

There are several OpenAI client libraries available for Crystal, but I need
one that types all possible objects and can be rapidly updated with the
frequent changes to the OpenAI API.

The initial schema / inspiration for this library was taken from the [go-openai](https://github.com/sashabaranov/go-openai)
library, as it provided a lot of helpful typings for things not documented in the
official swagger documentation.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     openai:
       github: christopherzimmerman/openai.cr
   ```

2. Run `shards install`

## Usage

```crystal
client = OpenAI::Client.new ENV["OPENAI_API_KEY"]

response = client.chat_completion(
    OpenAI::ChatCompletionRequest.new(
        model: OpenAI::GPT3DOT5_TURBO,
        messages: [
            OpenAI::ChatCompletionMessage.new(
                role: OpenAI::ChatMessageRole::User,
                content: "Hello there!"
            )
        ]
    )
)

puts response.choices[0].message.content
```

### Getting an OpenAI API Key:

1. Visit the OpenAI website at [https://platform.openai.com/account/api-keys](https://platform.openai.com/account/api-keys).
2. If you don't have an account, click on "Sign Up" to create one. If you do, click "Log In".
3. Once logged in, navigate to your API key management page.
4. Click on "Create new secret key".
5. Enter a name for your new key, then click "Create secret key".
6. Your new API key will be displayed. Use this key to interact with the OpenAI API.

**Note:** Your API key is sensitive information. Do not share it with anyone.

## Other Examples

<details>
<summary>Completion using a custom tool</summary>

```crystal
require "openai"

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
```
</details>

<details>
<summary>Basic chatbot</summary>

```crystal
require "openai"

client = OpenAI::Client.new ENV["OPENAI_API_KEY"]

req = OpenAI::ChatCompletionRequest.new(
    model: OpenAI::GPT3DOT5_TURBO,
    messages: [
        OpenAI::ChatCompletionMessage.new(
            role: OpenAI::ChatMessageRole::User,
            content: "You are a helpful chatbot."
        )
    ]
)

puts "Conversation (enter exit to exit)"
puts "-----------------"

while true
    print "> "
    message = gets.not_nil!
    exit unless message != "exit"

    req.messages << OpenAI::ChatCompletionMessage.new(
        role: OpenAI::ChatMessageRole::User,
        content: message
    )

    response = client.chat_completion(req)
    puts response.choices[0].message.content
    req.messages << response.choices[0].message
end
```
</details>

<details>
<summary>Create Embeddings</summary>

```crystal
require "openai"

client = OpenAI::Client.new ENV["OPENAI_API_KEY"]

embedding_request = OpenAI::EmbeddingRequest.new(
  input: ["Your input string goes here"],
  model: OpenAI::SMALL_EMBEDDING_3,
)

response = client.create_embeddings(embedding_request)

embedding_request_base64 = OpenAI::EmbeddingRequest.new(
    input: ["Your input string goes here"],
    model: OpenAI::SMALL_EMBEDDING_3,
    encoding_format: OpenAI::EmbeddingEncodingFormat::Base64
)

response2 = client.create_embeddings(embedding_request)

puts response.data[0] == response2.data[0]
```
</details>

## Contributing

1. Fork it (<https://github.com/your-github-user/openai.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Chris Zimmerman](https://github.com/christopherzimmerman) - creator and maintainer
