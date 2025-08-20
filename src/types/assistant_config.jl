"""
    AssistantConfig

Configuration for creating an assistant on the fly when calling the assistant API. 
See [Langodock Assistant API docs](https://docs.langdock.com/api-endpoints/assistant/assistant#assistant-configuration).

# Required Fields
- `name::String`: Name of the assistant (max 64 characters)
- `instructions::String`: System instructions for the assistant (max 16384 characters)

# Optional Fields
- `description::Union{String,Nothing}`: Description of the assistant (max 256 characters)
- `temperature::Union{Float64,Nothing}`: Temperature setting (0-1)
- `model::Union{String,Nothing}`: Specific model ID to use
- `capabilities::Union{Dict,Nothing}`: Features like web search, data analysis, image generation
- `actions::Union{Dict,Nothing}`: Custom API integrations
- `vector_db::Union{Dict,Nothing}`: Vector database connections
- `knowledge_folder_ids::Union{Vector,Nothing}`: IDs of knowledge folders
- `attachment_ids::Union{Vector,Nothing}`: UUIDs of attachments
"""
struct AssistantConfig
    name::String
    instructions::String
    description::Union{String,Nothing}
    temperature::Union{Float64,Nothing}
    model::Union{String,Nothing}
    capabilities::Union{Dict,Nothing}
    actions::Union{Dict,Nothing}
    vector_db::Union{Dict,Nothing}
    knowledge_folder_ids::Union{Vector,Nothing}
    attachment_ids::Union{Vector,Nothing}
    
    function AssistantConfig(
        name::String,
        instructions::String;
        description::Union{String,Nothing}=nothing,
        temperature::Union{Float64,Nothing}=nothing,
        model::Union{String,Nothing}=nothing,
        capabilities::Union{Dict,Nothing}=nothing,
        actions::Union{Dict,Nothing}=nothing,
        vector_db::Union{Dict,Nothing}=nothing,
        knowledge_folder_ids::Union{Vector,Nothing}=nothing,
        attachment_ids::Union{Vector,Nothing}=nothing
    )
        # Validate required fields
        length(name) > 64 && throw(ArgumentError("name must be 64 characters or less"))
        length(instructions) > 16384 && throw(ArgumentError("instructions must be 16384 characters or less"))
        
        # Validate optional fields
        !isnothing(description) && length(description) > 256 && throw(ArgumentError("description must be 256 characters or less"))
        !isnothing(temperature) && (temperature < 0 || temperature > 1) && throw(ArgumentError("temperature must be between 0 and 1"))
        
        new(
            name,
            instructions,
            description,
            temperature,
            model,
            capabilities,
            actions,
            vector_db,
            knowledge_folder_ids,
            attachment_ids
        )
    end
end

# JSON3 support
StructTypes.StructType(::Type{AssistantConfig}) = StructTypes.CustomStruct()

# Serialization: Convert to JSON with camelCase keys
StructTypes.lower(obj::AssistantConfig) = begin
    d = Dict{Symbol, Any}()
    d[:name] = obj.name
    d[:instructions] = obj.instructions
    !isnothing(obj.description) && (d[:description] = obj.description)
    !isnothing(obj.temperature) && (d[:temperature] = obj.temperature)
    !isnothing(obj.model) && (d[:model] = obj.model)
    !isnothing(obj.capabilities) && (d[:capabilities] = obj.capabilities)
    !isnothing(obj.actions) && (d[:actions] = obj.actions)
    !isnothing(obj.vector_db) && (d[:vectorDb] = obj.vector_db)
    !isnothing(obj.knowledge_folder_ids) && (d[:knowledgeFolderIds] = obj.knowledge_folder_ids)
    !isnothing(obj.attachment_ids) && (d[:attachmentIds] = obj.attachment_ids)
    return d
end

# Specify that we're lowering to a Dict
StructTypes.lowertype(::Type{AssistantConfig}) = Dict{Symbol, Any}

# Deserialization: Convert from JSON with camelCase back to snake_case
StructTypes.construct(::Type{AssistantConfig}, d::Dict; kw...) = begin
    # Convert camelCase keys to snake_case
    snake_case_dict = Dict{Symbol, Any}()
    
    for (key, value) in d
        # Convert string keys to symbols if necessary
        key_sym = key isa String ? Symbol(key) : key
        
        # Map camelCase to snake_case
        snake_key = if key_sym == :vectorDb
            :vector_db
        elseif key_sym == :knowledgeFolderIds
            :knowledge_folder_ids
        elseif key_sym == :attachmentIds
            :attachment_ids
        else
            key_sym
        end
        snake_case_dict[snake_key] = value
    end
    
    # Extract values with defaults for required fields
    name = get(snake_case_dict, :name, "")
    instructions = get(snake_case_dict, :instructions, "")
    
    # Extract optional fields
    description = get(snake_case_dict, :description, nothing)
    temperature = get(snake_case_dict, :temperature, nothing)
    model = get(snake_case_dict, :model, nothing)
    capabilities = get(snake_case_dict, :capabilities, nothing)
    actions = get(snake_case_dict, :actions, nothing)
    vector_db = get(snake_case_dict, :vector_db, nothing)
    knowledge_folder_ids = get(snake_case_dict, :knowledge_folder_ids, nothing)
    attachment_ids = get(snake_case_dict, :attachment_ids, nothing)
    
    # Construct the AssistantConfig
    AssistantConfig(
        name,
        instructions;
        description=description,
        temperature=temperature,
        model=model,
        capabilities=capabilities,
        actions=actions,
        vector_db=vector_db,
        knowledge_folder_ids=knowledge_folder_ids,
        attachment_ids=attachment_ids
    )
end

