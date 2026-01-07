# Assistant API for Langdock
#
# Docs: https://docs.langdock.com/api-endpoints/assistant


"""
    create_assistant_chat

Create a chat completion using an assistant via Langdock API.

# Example
```julia
# Using existing assistant
response = assistant_chat_completion(
    provider,
    [Dict("role" => "user", "content" => "Hello!")],
    assistant_id="asst_123"
)
# Using temporary assistant configuration
assistant_config = Dict(
    "model" => "gpt-4o",
    "instructions" => "You are a helpful assistant"
)
response = create_assistant_chat(
    provider,
    [Dict("role" => "user", "content" => "Hello!")],
    assistant=assistant_config
)
```
"""
function create_assistant_chat(
    api_key::String,
    messages;
    assistant_id::Union{String, Nothing}=nothing,
    assistant::Union{AssistantConfig, Nothing}=nothing,
    output::Union{Dict, Nothing}=nothing,
    attachment_ids::Union{Vector{String}, Nothing}=nothing,
    http_kwargs::NamedTuple = NamedTuple(),
#   streamcallback = nothing, # not supported for this endpoint
    kwargs...
)
    # Validate that exactly one of assistant_id or assistant is provided
    (isnothing(assistant_id) && isnothing(assistant)) && throw(ArgumentError("Either assistant_id or assistant must be provided"))
    (!isnothing(assistant_id) && !isnothing(assistant)) && throw(ArgumentError("Cannot provide both assistant_id and assistant"))

    langdock_request(
        "/assistant/{api_version}/chat/completions",
        api_key;
        method = "POST",
        http_kwargs = http_kwargs,
        assistantId = assistant_id, 
        assistant = assistant,
        messages = messages,
        output = output,
        attachmentIds = attachment_ids, # yes, the Langdock API expects JS syntax instead of json :(
        streamcallback = nothing,
        kwargs...
    )
end

function create_assistant_chat(
    provider::AbstractLangdockProvider,
    messages;
    assistant_id::Union{String, Nothing}=nothing,
    assistant::Union{AssistantConfig, Nothing}=nothing,
    output::Union{Dict, Nothing}=nothing,
    attachment_ids::Union{Vector{String}, Nothing}=nothing,
    http_kwargs::NamedTuple = NamedTuple(),
    #streamcallback = nothing,
    kwargs...
)

    # Validate that exactly one of assistant_id or assistant is provided
    (isnothing(assistant_id) && isnothing(assistant)) && throw(ArgumentError("Either assistant_id or assistant must be provided"))
    (!isnothing(assistant_id) && !isnothing(assistant)) && throw(ArgumentError("Cannot provide both assistant_id and assistant"))

    langdock_request(
        "/assistant/{api_version}/chat/completions",
        provider;
        method = "POST",
        http_kwargs = http_kwargs,
        assistantId = assistant_id, # yes, the Langdock API expects JS syntax isntead of json :(
        assistant = assistant,
        messages = messages,
        output = output,
        attachmentIds = attachment_ids, # yes, the Langdock API expects JS syntax instead of json :(
        streamcallback = nothing,
        kwargs...
    )
end

"""
    list_assistant_models

List all available models for the assistant API.
"""
function list_assistant_models(
    api_key::String;
    http_kwargs::NamedTuple = NamedTuple()
)
    langdock_request(
        "/assistant/{api_version}/models",
        api_key;
        method = "GET",
        http_kwargs = http_kwargs
    )
end

function list_assistant_models(
    provider::AbstractLangdockProvider;
    http_kwargs::NamedTuple = NamedTuple()
)
     langdock_request(
        "/assistant/{api_version}/models",
        provider;
        method = "GET",
        http_kwargs = http_kwargs
    )

end