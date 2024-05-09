# Copyright (c) 2024 OpenAI.cr Contributors
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

module OpenAI
  record(
    EditsRequest,
    model : String? = nil,
    input : String? = nil,
    instruction : String? = nil,
    n : Int32? = nil,
    temperature : Float32? = nil,
    top_p : Float32? = nil
  ) do
    include JSON::Serializable
  end

  record(
    EditsChoice,
    text : String,
    index : Int32,
  ) do
    include JSON::Serializable
  end

  record(
    EditsResponse,
    object : String,
    created : Int64,
    usage : Usage,
    choices : Array(EditsChoice),
  ) do
    include JSON::Serializable
  end
end
