# Copyright (c) 2024 OpenAI.cr Contributors
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

module OpenAI
	ADA_SIMILARITY            = "text-similarity-ada-001"
	BABBAGE_SIMILARITY        = "text-similarity-babbage-001"
	CURIE_SIMILARITY          = "text-similarity-curie-001"
	DAVINCI_SIMILARITY        = "text-similarity-davinci-001"
	ADA_SEARCH_DOCUMENT       = "text-search-ada-doc-001"
	ADA_SEARCH_QUERY          = "text-search-ada-query-001"
	BABBAGE_SEARCH_DOCUMENT   = "text-search-babbage-doc-001"
	BABBAGE_SEARCH_QUERY      = "text-search-babbage-query-001"
	CURIE_SEARCH_DOCUMENT     = "text-search-curie-doc-001"
	CURIE_SEARCH_QUERY        = "text-search-curie-query-001"
	DAVINCI_SEARCH_DOCUMENT   = "text-search-davinci-doc-001"
	DAVINCI_SEARCH_QUERY      = "text-search-davinci-query-001"
	ADA_CODE_SEARCH_CODE      = "code-search-ada-code-001"
	ADA_CODE_SEARCH_TEXT      = "code-search-ada-text-001"
	BABBAGE_CODE_SEARCH_CODE  = "code-search-babbage-code-001"
	BABBAGE_CODE_SEARCH_TEXT  = "code-search-babbage-text-001"
	ADA_EMBEDDING_V2          = "text-embedding-ada-002"
	SMALL_EMBEDDING_3         = "text-embedding-3-small"
	LARGE_EMBEDDING_3         = "text-embedding-3-large"

    enum EmbeddingEncodingFormat
        Float
        Base64
    end

    record(
        Embedding,
        object : String,
        embedding : Array(Float32),
        index : Int32,
    ) do
        include JSON::Serializable

        def dot_product(other : Embedding) : Float32
            if @embedding.size != other.embedding.size
                raise Exceptions::VectorLengthMismatch.new
            end

            @embedding.zip(other.embedding).reduce(0_f32) do |memo, val|
                memo + val[0] * val[1]
            end
        end
    end

    record(
        EmbeddingResponse,
        object : String,
        data : Array(Embedding),
        model : String,
        usage : Usage,
    ) do
        include JSON::Serializable
    end

    alias Base64String = String

    class Base64String
        def decode
            a = Base64.decode(self)
            a.in_slices_of(4).map do |group|
                group_as_slice = Slice.new(group.size) { |i| group[i] }
                IO::ByteFormat::LittleEndian.decode(Float32, group_as_slice)
            end
        end
    end

    record(
        Base64Embedding,
        object : String,
        embedding : Base64String,
        index : Int32,
    ) do
        include JSON::Serializable
    end

    record(
        EmbeddingResponseBase64,
        object : String,
        data : Array(Base64Embedding),
        model : String,
        usage : Usage,
    ) do
        include JSON::Serializable

        def to_embedding_response : EmbeddingResponse
            decoded_data = @data.map do |item|
                Embedding.new(object: item.object, embedding: item.embedding.decode, index: item.index)
            end

            EmbeddingResponse.new(object: @object, data: decoded_data, model: @model, usage: @usage)
        end
    end

    record(
        EmbeddingRequest,
        input : Array(String) | (Array(Array(Int32))),
        model : String,
        user : String? = nil,
        encoding_format : EmbeddingEncodingFormat? = nil,
        dimensions : Int32? = nil,
    ) do
        include JSON::Serializable
    end

    class Client
        def create_embeddings(request : EmbeddingRequest) : EmbeddingResponse
            path = "/v1/embeddings"
            headers = HTTP::Headers.new
            headers.add("Content-Type", "application/json")
            headers.add("Authorization", "Bearer #{config.auth_token}")
            response = config.http_client.post(path, headers: headers, body: request.to_json)
            
            if request.encoding_format == EmbeddingEncodingFormat::Base64
                EmbeddingResponseBase64.from_json(response.body).to_embedding_response
            else
                EmbeddingResponse.from_json(response.body)
            end
        end
    end
end