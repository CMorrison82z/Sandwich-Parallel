--[[
-- This implementation assumes the `job_instructions` are a module script that return a `function`.
--
-- Jobs are mapped one time with one actor to reduce duplicate cached data per actor. I.e., think of each
-- job having a dedicated actor.
--]]

-- ## SERVICES ## --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Cache = require("distributers.roblox.cache")--require(script.Parent.cache)


-- ## VARIABLES ## --

local DEFAULT_ACTORS = 64

local container = Instance.new("Folder")
container.Name = "Actors"
container.Parent = if RunService:IsClient() then Players.LocalPlayer.PlayerScripts else ServerScriptService

local actor_script = if RunService:IsClient() then script.Parent.client_actor else script.Parent.server_actor

assert(not actor_script.Enabled, "Actor scripts should be disabled")

-- ## SETUP ## --

local actors = {}
local actorIndex = 1

local actors_cache = Cache.new(
    DEFAULT_ACTORS,
    function ()
        local newActor = Instance.new("Actor")

        local _ended_event = Instance.new("BindableEvent")
        _ended_event.Name = "SandwichEnd"
        _ended_event.Parent = newActor

        local _actor_script = actor_script:Clone()
        _actor_script.Parent = newActor
        _actor_script.Enabled = true

        newActor.Parent = container

        _actors_modules_initialized[newActor] = {}

        return newActor
    end
)

local job_actor_map = {}

return function(module_script, ...)
	local actor : Actor = job_actor_map[module_script]

	-- Cannot require modules in parallel, so we must do it separately.
	if not actor then
        actor = actors_cache:get()

		actor:SendMessage("SandwichInit", module_script)
		actor.SandwichEnd.Event:Wait()

		job_actor_map[module_script] = actor
	end
	
	actor:SendMessage("SandwichStart", module_script, ...)
	actor.SandwichEnd.Event:Wait()
end
