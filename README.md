# Langdock.jl - Julia wrapper for the Langdock API (Unofficial)

This is an unofficial wrapper for [Langdock](https://www.langdock.com/) API.

## Implementation Status

| Category | Endpoint | Description | Implemented |
|----------|----------|-------------|-------------|
| **Completion API** | | | |
| | `POST /openai/{region}/v1/chat/completions` | OpenAI chat completions | ❌ |
| | `POST /anthropic/{region}/v1/messages` | Anthropic messages | ❌ |
| | `POST /mistral/{region}/v1/fim/completions` | Codestral completions | ❌ |
| **Embedding API** | | | |
| | `POST /openai/{region}/v1/embeddings` | OpenAI embeddings | ✅ |
| **Assistant API** | | | |
| | `POST /assistant/v1/chat/completions` | Assistant chat completions | ✅ |
| | `GET /assistant/v1/models` | List assistant models | ⚠️ |
| | `POST /attachment/v1/upload` | Upload attachment | ❌ |
| **Knowledge Folder API** | | | |
| | `POST /knowledge/{folderId}` | Upload file | ❌ |
| | `PATCH /knowledge/{folderId}` | Update attachment | ❌ |
| | `GET /knowledge/{folderId}/list` | Retrieve files | ❌ |
| | `DELETE /knowledge/{folderId}/{attachmentId}` | Delete attachment | ❌ |
| | `POST /knowledge/search` | Search knowledge folder | ❌ |

**Notes:**
- ✅ Fully implemented and working
- ⚠️ Implemented but has issues (HTTP.jl compatibility issue, works with curl)
- ❌ Not yet implemented

## Usage Examples

### Using Implemented Endpoints

```julia
using Langdock

# Set up provider
ENV["LANGDOCK_API_KEY"] = "your-api-key"
provider = LangdockProvider(api_key=ENV["LANGDOCK_API_KEY"], region="eu") # or get_default_provider()

# List available assistant models
models = list_assistant_models(provider) # not working due to issue with HTTP.jl when calling this endpoint

# Create assistant chat
messages = [Dict("role" => "user", "content" => "Hello!")]
response = create_assistant_chat(
   provider,
   messages,
   assistant_id="<your-assistant-id>"
)

# Generate embeddings
embeddings = create_openai_embeddings(
   provider,
   "Text to embed",
   model_id="text-embedding-ada-002" 
)
```

## Contributing

To implement additional endpoints:

1. Create a new file in `src/api/` for the endpoint category (if not exists)
2. Implement the function following the existing pattern:
   - Support both `api_key` and `provider` parameters
   - Use `langdock_request` for API calls
   - Add proper documentation with examples
3. Export the function in `src/Langdock.jl`
4. Add tests in the corresponding `test/api/` file
5. Update this documentation

## Next Steps for Implementation

Priority endpoints to implement:
1. OpenAI Chat Completions - Most commonly used endpoint
2. Anthropic Messages - Support for Claude models
3. Knowledge Folder operations - File management capabilities
4. Mistral/Codestral - Code completion support

## References

- [Langdock API Documentation](https://docs.langdock.com/api-endpoints/)