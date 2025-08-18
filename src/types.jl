"""
    LangdockProvider

Configuration for connecting to the Langdock API.

# Fields
- `api_key`: API key for authentication
- `api_version`: API version to use (default: "v1")
- `base_url`: Base URL for the API (default: https://api.langdock.com)
- `region`: Region for the API endpoints ("eu" or "us", default: "eu")
- `timeout`: Request timeout in seconds (default: 30)
"""
mutable struct LangdockProvider
    api_key::String
    api_version::String
    base_url::String
    region::String
    timeout::Int
    
    function LangdockProvider(;
        api_key::String="",
        api_version::String=DEFAULT_API_VERSION,
        base_url::String=DEFAULT_BASE_URL,
        region::String=DEFAULT_REGION,
        timeout::Int=DEFAULT_TIMEOUT
    )
        isempty(api_key) && throw(ArgumentError("API key cannot be empty"))
        !(api_version in API_VERSIONS) && throw(ArgumentError("Invalid API version: $api_version. Must be one of: $API_VERSIONS"))
        !(region in REGIONS) && throw(ArgumentError("Region must be one of $REGIONS, got: $region"))
        timeout <= 0 && throw(ArgumentError("Timeout must be positive, got: $timeout"))
        
        new(api_key, api_version, base_url, region, timeout)
    end
end

"""
    LangdockResponse

Wrapper for API responses from Langdock endpoints.

# Fields
- `response`: The raw HTTP.Response object
- `data`: Parsed JSON data as a Dict, or nothing if parsing fails
"""
struct LangdockResponse
    response::HTTP.Response
    data::Union{Dict, Nothing}
    
    function LangdockResponse(response::HTTP.Response)
        data = try
            JSON3.read(response.body, Dict)
        catch
            nothing
        end
        new(response, data)
    end
end

abstract type AbstractMessage end

"""
    Message

Represents a message in a conversation.

# Fields
- `role`: The role of the message sender ("user", "assistant", "system", "tool")
- `content`: The content of the message (String or Vector for multimodal)
"""
struct Message <: AbstractMessage
    role::String
    content::Union{String, Vector{Any}}

    function Message(
        role::String,
        content::Union{String, Vector{Any}}
    )
        !(role in ["user", "assistant", "system", "tool"]) && throw(ArgumentError("Invalid role: $role. Must be one of: user, assistant, system, tool"))
        new(role, content)
    end

end

# Helper function to convert Message to Dict for API requests
function to_dict(msg::Message)::Dict
    Dict{String, Any}("role" => msg.role, "content" => msg.content)
end

"""
    AssistantMessage   
Represents a message in an assistant conversation.
"""
struct AssistantMessage  <: AbstractMessage
    role::String
    content::Union{String, Vector{Any}}
    attachmentIds::Union{Vector{<:String}, Nothing}

    function AssistantMessage(
        role::String,
        content::Union{String, Vector{Any}};
        attachmentIds::Union{Vector{<:String}, Nothing}=nothing
    )
        !(role in ["user", "assistant", "system", "tool"]) && throw(ArgumentError("Invalid role: $role. Must be one of: user, assistant, system, tool"))
        new(role, content, attachmentIds)
    end
end 

function to_dict(msg::AssistantMessage)::Dict
    d = Dict{String, Any}("role" => msg.role, "content" => msg.content)
    !isnothing(msg.attachmentIds) && (d["attachmentIds"] = msg.attachmentIds)
    return d
end


"""
    LangdockError

Custom exception type for Langdock API errors.

# Fields
- `message`: Error message
- `status_code`: HTTP status code (if applicable)
- `response`: The full error response from the API
"""
struct LangdockError <: Exception
    message::String
    status_code::Union{Int, Nothing}
    response::Union{Dict, Nothing}
    
    function LangdockError(message::String; status_code=nothing, response=nothing)
        new(message, status_code, response)
    end
end

# Custom show method for better error display
function Base.show(io::IO, e::LangdockError)
    print(io, "LangdockError: $(e.message)")
    !isnothing(e.status_code) && print(io, " (HTTP $(e.status_code))")
    !isnothing(e.response) && print(io, "\nResponse: ", JSON3.write(e.response))
end