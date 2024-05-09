require "../../src/openai"

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
