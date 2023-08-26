local _cache = {}

local _ended_event = script.SandwichEnd

script.Parent:BindToMessageParallel("SandwichStart", function(module_script, ...)
	local required_module = _cache[module_script]

	if not required_module then
		required_module = require(module_script.Module)
        _cache[module_script] = required_module
	end

    required_module(...)

    _ended_event:Fire()
end)
