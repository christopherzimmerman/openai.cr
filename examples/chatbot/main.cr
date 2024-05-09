require "../../src/openai"

client = OpenAI::Client.new ENV["OPENAI_API_KEY"]

req = OpenAI::ChatCompletionRequest.new(
  model: OpenAI::GPT3DOT5_TURBO,
  messages: [
    OpenAI::ChatCompletionMessage.new(
      role: OpenAI::ChatMessageRole::User,
      content: "You are a helpful chatbot."
    ),
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
