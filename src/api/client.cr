# Copyright (c) 2024 OpenAI.cr Contributors
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

module OpenAI
    class Client
        getter config : ClientConfig

        def initialize(auth_token : String)
            @config = ClientConfig.new auth_token: auth_token
        end

        private def get_headers : HTTP::Headers
            headers = HTTP::Headers.new
            headers = HTTP::Headers.new
            headers.add("Content-Type", "application/json")
            headers.add("Authorization", "Bearer #{config.auth_token}")
            headers
        end

        private def make_request(path : String, request : U, response_type : V.class) : V forall U, V
            make_request(path, request, response_type) do |headers|
            end
        end

        private def make_request(path : String, request : U, response_type : V.class) : V forall U, V
            headers = self.get_headers
            yield headers
            response = config.http_client.post(path, headers: headers, body: request.to_json)
            return V.from_json(response.body)
        end

        private def make_get_request(path : String, response_type : U.class) : U forall U
            headers = self.get_headers
            yield headers
            response = config.http_client.get(path, headers: headers)
            return U.from_json(response.body)
        end

        private def make_get_request(path : String, response_type : U.class) : U forall U
            make_get_request(path, response_type) do |headers|
            end
        end
    end
end