# Langdock.jl - Julia wrapper for the Langdock API (Unofficial)


## Implementation Status

### ✅ Implemented Endpoints

#### Assistant API
1. **List Assistant Models** 
   
   (❌ not working due to an issue when using HTTP.jl, works fine with `curl`)
   - **Endpoint**: `GET /assistant/v1/models`
   - **Julia Function**: `list_assistant_models(api_key)` or `list_assistant_models(provider)`
   - **Description**: List all available models for the Assistant API
   - **File**: `src/api/assistants.jl:96-119`

2. **Create Assistant Chat**
   - **Endpoint**: `POST /assistant/v1/chat/completions`
   - **Julia Function**: `create_assistant_chat(api_key, messages; assistant_id, assistant, output, attachment_ids)`
   - **Description**: Creates a model response for a given Assistant
   - **Parameters**:
     - `messages`: Array of message objects
     - `assistant_id`: ID of existing assistant (mutually exclusive with `assistant`)
     - `assistant`: AssistantConfig for temporary assistant (mutually exclusive with `assistant_id`)
     - `output`: Optional output configuration
     - `attachment_ids`: Optional array of attachment IDs
   - **File**: `src/api/assistants.jl:31-89`

#### Embeddings API
1. **Create OpenAI Embeddings**
   - **Endpoint**: `POST /openai/{region}/v1/embeddings`
   - **Julia Function**: `create_openai_embeddings(api_key, input, model_id)`
   - **Description**: Generate embeddings for input text using OpenAI models
   - **Parameters**:
     - `input`: Text or array of texts to generate embeddings for
     - `model_id`: Model ID (defaults to configured default)
     - `region`: EU or US (handled by provider configuration)
   - **File**: `src/api/embeddings.jl:27-62`

### ❌ Not Yet Implemented Endpoints

#### Completion API
1. **OpenAI Chat Completions**
   - **Endpoint**: `POST /openai/{region}/v1/chat/completions`

2. **Anthropic Messages**
   - **Endpoint**: `POST /anthropic/{region}/v1/messages`

3. **Mistral/Codestral Completions**
   - **Endpoint**: `POST /mistral/{region}/v1/fim/completions`

#### Assistant API (Additional Endpoints)
1. **Upload Attachment**
   - **Endpoint**: `POST /assistant/v1/attachments` (exact path TBD)
   - **Description**: Upload attachments for use with assistants

#### Knowledge Folder API
1. **Share Knowledge Folders**
   - **Description**: Share knowledge folders with API keys

2. **Upload File**
   - **Endpoint**: `POST /knowledge/{folderId}`
   - **Description**: Upload a file to a knowledge folder

3. **Update Attachment**
   - **Endpoint**: `PATCH /knowledge/{folderId}`
   - **Description**: Update an existing attachment in a knowledge folder

4. **Retrieve Files**
   - **Endpoint**: `GET /knowledge/{folderId}/list`
   - **Description**: List all files in a knowledge folder

5. **Delete Attachment**
   - **Endpoint**: `DELETE /knowledge/{folderId}/{attachmentId}`
   - **Description**: Delete a specific attachment from a knowledge folder

6. **Search Knowledge Folder**
   - **Endpoint**: `POST /knowledge/search`
   - **Description**: Search within knowledge folders

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