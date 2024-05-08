# Copyright (c) 2024 OpenAI.cr Contributors
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

module OpenAI
    record(
        Usage,
        prompt_tokens : Int32,
        total_tokens : Int32,
        completion_tokens : Int32? = nil,
    ) do
        include JSON::Serializable
    end
end