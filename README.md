## Notes

- `before` and `after` jobs have been removed for now.

## Example job instructions handlers

```lua
-- Default behavior :
local function default_job_getter(f)
    return f
end

do
    -- Distribute job instructions to actor
    local function rbx_disributer(instructions_list, ...)
        local next_actor = next(actors)

        next_actor:SendMessage(instructions_list, ...)
    end

    -- Example implementation in an Actor script to follow job retrieval instruction.
    -- TODO: memoize already required modules ?
    local function roblox_job_getter(instructions)
        return require(instructions.Module)[instructions.Name]
    end
end
```
