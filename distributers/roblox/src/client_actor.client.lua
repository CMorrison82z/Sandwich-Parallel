local _cache = {}

local _ended_event = script.Parent.SandwichEnd

script.Parent:BindToMessage("SandwichInit", function(module_script, ...)
	_cache[module_script] = require(module_script)
	
	_ended_event:Fire()
end)

script.Parent:BindToMessageParallel("SandwichStart", function(module_script, ...)		
	_cache[module_script](...)
	
	_ended_event:Fire()
end)