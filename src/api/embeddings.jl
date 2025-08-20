# Langdock API for OpenAI Embeddings
# 
# Docs: https://docs.langdock.com/api-endpoints/embedding/openai-embedding

"""
    craate_openai_embeddings(
        api_key::String,
        input,
        model_id::String = DEFAULT_EMBEDDING_MODEL_ID;
        http_kwargs::NamedTuple = NamedTuple(),
        kwargs...
    )

# Arguments:
- `api_key::String`: Langdock API key
- `input`: The input text to generate the embedding(s) for, as String or array of tokens.
    To get embeddings for multiple inputs in a single request, pass an array of strings
        or array of token arrays. Each input must not exceed 8192 tokens in length.
        - `model_id::String`: Model id. Defaults to $DEFAULT_EMBEDDING_MODEL_ID.

        # Keyword Arguments:
        - `http_kwargs::NamedTuple`: Optional. Keyword arguments to pass to HTTP.request.

        For additional details about the endpoint, visit <hhttps://docs.langdock.com/api-endpoints/embedding/openai-embedding>
        """

function create_openai_embeddings(
    api_key::String,
    input,
    model_id::String = DEFAULT_EMBEDDING_MODEL_ID;
    http_kwargs::NamedTuple = NamedTuple(),
    kwargs...
)
    langdock_request(
        "/openai/{region}/{api_version}/embeddings",
        api_key;
        method = "POST",
        http_kwargs = http_kwargs,
        model = model_id,
        input,
        kwargs...
    )
end

function create_openai_embeddings(
    provider::AbstractLangdockProvider,
    input;
    model_id::String = DEFAULT_EMBEDDING_MODEL_ID,   
    http_kwargs::NamedTuple=NamedTuple(),
    streamcallback=nothing,
    kwargs...
)
    langdock_request(
        "/openai/{region}/{api_version}/embeddings",
        provider;
        method="POST",
        http_kwargs=http_kwargs,
        model=model_id,
        input,
        kwargs...
    )
end