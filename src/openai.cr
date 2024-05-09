require "base64"
require "http/client"
require "http/headers"
require "json"
require "uri/params"
require "./jsonschema/json"
require "./api/exceptions"
require "./api/common"
require "./api/config"
require "./api/chat"
require "./api/completion"
require "./api/assistant"
require "./api/client"
require "./api/embeddings"

module OpenAI
  VERSION = "0.1.0"
end
