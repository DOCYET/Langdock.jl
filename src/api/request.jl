"""
    Basic API request functions for Langdock API.
"""

"""
    auth_header(provider::AbstractLangdockProvider, api_key::AbstractString)

Return the authorization header for the given provider and API key.
"""
auth_header(provider::AbstractLangdockProvider) = auth_header(provider, provider.api_key)

function auth_header(::LangdockProvider, api_key::AbstractString)
    isempty(api_key) && throw(ArgumentError("api_key cannot be empty"))
    [
        "Authorization" => "Bearer $api_key",
        "Content-Type" => "application/json",
    ]
end


"""
    build_url(provider::LangdockProvider, endpoint::String)

Build the complete URL for an API endpoint.

# Arguments
- `provider`: The LangdockProvider configuration
- `endpoint`: The API endpoint path

# Returns
- `String`: The complete URL

# Example
```julia
url = build_url(provider, "/openai/{region}/{api_version}/chat/completions")
# Returns: "https://api.langdock.com/openai/eu/v1/chat/completions"
```
"""
function build_url(provider::LangdockProvider, endpoint::String)::String
    # Remove leading slash if present
    endpoint = lstrip(endpoint, '/')
    
    # Handle region-specific endpoints
    if occursin("{region}", endpoint) 
        endpoint = replace(endpoint, "{region}" => provider.region)
    end

    if occursin("{api_version}", endpoint)
        endpoint = replace(endpoint, "{api_version}" => provider.api_version)
    end
     
    # Build complete URL
    base_url = rstrip(provider.base_url, '/')
    return "$base_url/$endpoint"
end


"""
    build_params(kwargs::Dict)  

Build a JSON body from keyword arguments.  
"""
function build_params(kwargs)
    filtered_kwargs = Dict(k => v for (k, v) in pairs(kwargs) if !isnothing(v))

    isempty(filtered_kwargs) && return nothing
    
    buf = IOBuffer()
    JSON3.write(buf, filtered_kwargs)
    seekstart(buf)
    return buf
end

""" 
    request_body(url::String, method::AbstractString; input, headers, query, kwargs...)

Make a request to the given URL with the specified method and input.
"""
function request_body(url, method; input, headers, query, kwargs...)
    input = isnothing(input) ? [] : input

    resp = HTTP.request(
        method,
        url;
        body = input,
        query = query,
        headers = headers,
        kwargs...
    )
    return resp, resp.body
end

"""
    request_body_live(url::String; method, input, headers, streamcallback, kwargs...)

Make a live request to the given URL with the specified method and input, streaming the response.
"""
function request_body_live(url; method, input, headers, streamcallback, kwargs...)
    resp = nothing

    body = sprint() do output
        resp = HTTP.open("POST", url, headers) do stream
            body = String(take!(input))
            write(stream, body)

            HTTP.closewrite(stream)    # indicate we're done writing to the request

            r = HTTP.startread(stream) # start reading the response
            isdone = false

            while !isdone
                if eof(stream)
                    break
                end
                # Extract all available messages
                masterchunk = String(readavailable(stream))

                # Split into subchunks on newlines.
                # Occasionally, the streaming will append multiple messages together,
                # and iterating through each line in turn will make sure that
                # streamingcallback is called on each message in turn.
                chunks = String.(filter(!isempty, split(masterchunk, "\n")))

                # Iterate through each chunk in turn.
                for chunk in chunks
                    if occursin(chunk, "data: [DONE]")  # TODO - maybe don't strip, but instead us a regex in the endswith call
                        isdone = true
                        break
                    end

                    # call the callback (if present) on the latest chunk
                    if !isnothing(streamcallback)
                        streamcallback(chunk)
                    end

                    # append the latest chunk to the body
                    print(output, chunk)
                end
            end
            HTTP.closeread(stream)
        end
    end

    return resp, body
end

""" 
    status_error(resp, log = nothing)

Raise an error based on the HTTP response status code.
"""
function status_error(resp, log = nothing)
    logs = !isnothing(log) ? ": $log" : ""
    error("request status $(resp.message)$logs")
end

"""
    _request 

Make a request to the Langdock API with the specified parameters. It handles both synchronous and streaming requests.
"""
function _request(
    endpoint::AbstractString,
    provider::AbstractLangdockProvider,
    api_key::AbstractString = provider.api_key;
    method,
    query = nothing,
    http_kwargs,
    streamcallback = nothing,
    additional_headers::AbstractVector = Pair{String, String}[],
    kwargs...
)
    # add stream: True to the API call if a stream callback function is passed
    if !isnothing(streamcallback)
        kwargs = (kwargs..., stream = true)
    end

    
    params = build_params(kwargs)
    url = build_url(provider, endpoint)
    
    resp, body = let
        # Add whatever other headers we were given
        headers = vcat(auth_header(provider, api_key), additional_headers)

        if isnothing(streamcallback)
            request_body(
                url,
                method;
                input = params,
                headers = headers,
                query = query,
                http_kwargs...
            )
        else
            request_body_live(
                url;
                method,
                input = params,
                headers = headers,
                query = query,
                streamcallback = streamcallback,
                http_kwargs...
            )
        end
    end
    if resp.status >= 400
        status_error(resp, body)
    else
        return if isnothing(streamcallback)
            LangdockResponse(resp.status, JSON3.read(body))
        else
            # Assemble the streaming response body into a proper JSON object
            lines = split(body, "\n")  # Split body into lines

            # Filter out empty lines and lines that are not JSON (e.g., "event: ...")
            lines = filter(x -> !isempty(x) && startswith(x, "data: "), lines)

            # Parse each line, removing the "data: " prefix
            parsed = map(line -> JSON3.read(line[7:end]), lines)

            LangdockResponse(resp.status, parsed)
        end
    end
end

"""
    langdock_request

Make a request to the Langdock API with the specified parameters using the default provider.
"""
function langdock_request(
    api::AbstractString,
    api_key::AbstractString;
    method,
    http_kwargs,
    streamcallback = nothing,
    kwargs...
)
    _request(
        api,
        get_default_provider(),
        api_key;
        method,
        http_kwargs,
        streamcallback = streamcallback,
        kwargs...
    )
end

function langdock_request(
    api::AbstractString,
    provider::AbstractLangdockProvider;
    method,
    http_kwargs,
    streamcallback = nothing,
    kwargs...
)
    _request(api, provider; method, http_kwargs, streamcallback = streamcallback, kwargs...)
end