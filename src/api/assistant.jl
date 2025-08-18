"""
    assistant_chat_completion(provider, messages; assistantId=nothing, assistant=nothing, output=nothing, attachmentIds=nothing, headers=Dict(), kwargs...)

Create a chat completion using an assistant via Langdock API.

# Arguments
- `provider::LangdockProvider`: Provider configuration
- `messages::Vector`: List of conversation messages

# Keyword Arguments
- `assistantId::Union{String, Nothing}=nothing`: ID of an existing assistant
- `assistant::Union{Dict, Nothing}=nothing`: Assistant configuration object
- `output::Union{Dict, Nothing}=nothing`: Structured output configuration
- `attachmentIds::Union{Vector{String}, Nothing}=nothing`: File attachment UUIDs
- `headers::Dict=Dict()`: Additional headers
- Additional assistant API parameters can be passed as keyword arguments

# Returns
- `LangdockResponse`: The API response

# Note
Either `assistantId` or `assistant` must be provided, but not both.

# Example
```julia
# Using existing assistant
response = assistant_chat_completion(
    provider,
    [Dict("role" => "user", "content" => "Hello!")],
    assistantId="asst_123"
)

# Using temporary assistant configuration
assistant_config = Dict(
    "model" => "gpt-4o",
    "instructions" => "You are a helpful assistant"
)
response = assistant_chat_completion(
    provider,
    [Dict("role" => "user", "content" => "Hello!")],
    assistant=assistant_config
)
```
"""
function assistant_chat_completion(
    provider::LangdockProvider,
    messages::Vector{<:AbstractMessage};
    assistantId::Union{String, Nothing}=nothing,
    assistant::Union{Dict, Nothing}=nothing,
    output::Union{Dict, Nothing}=nothing,
    attachmentIds::Union{Vector{String}, Nothing}=nothing,
    headers::Dict=Dict(),
    kwargs...
)::LangdockResponse
    
    # Validate that exactly one of assistantId or assistant is provided
    (isnothing(assistantId) && isnothing(assistant)) && throw(ArgumentError("Either assistantId or assistant must be provided"))
    (!isnothing(assistantId) && !isnothing(assistant)) && throw(ArgumentError("Cannot provide both assistantId and assistant"))
    
    endpoint = "/assistant/{api_version}/chat/completions"

    body = Dict{String, Any}(
        "messages" => messages
    )
    
    # Add assistant identification
    !isnothing(assistantId) && (body["assistantId"] = assistantId)
    !isnothing(assistant) && (body["assistant"] = assistant)
    
    # Add optional parameters
    !isnothing(output) && (body["output"] = output)
    !isnothing(attachmentIds) && (body["attachmentIds"] = attachmentIds)
    
    # Add any additional parameters
    for (key, value) in kwargs
        body[string(key)] = value
    end
    
    simple_request(provider, endpoint, body; headers=headers)
end

"""
    assistant_models(provider; headers=Dict())

List all available models for the assistant API.

# Arguments
- `provider::LangdockProvider`: Provider configuration

# Keyword Arguments
- `headers::Dict=Dict()`: Additional headers

# Returns
- `LangdockResponse`: The API response containing list of available models

# Example
```julia
response = assistant_models(provider)
models_data = response.data
```
"""
function assistant_models(
    provider::LangdockProvider;
    headers::Dict=Dict()
)::LangdockResponse
    
    endpoint = "/assistant/{api_version}/models"
    url = build_url(provider, endpoint)
    
    @debug "Getting assistant models" url=url
    
    simple_request(provider, endpoint, Dict(); headers=headers)
end