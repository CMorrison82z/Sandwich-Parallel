--[[
-- This implementation assumes the `job_instructions` are a module script that return a `function`
--]]

-- ## SERVICES ## --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

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

local _actors_modules_initialized = {}

actorCount = actorCount or DEFAULT_ACTORS

for _ = 1, actorCount do
	local newActor = Instance.new("Actor")

	local _ended_event = Instance.new("BindableEvent")
	_ended_event.Name = "SandwichEnd"
	_ended_event.Parent = newActor

	local _actor_script = actor_script:Clone()
	_actor_script.Parent = newActor
	_actor_script.Enabled = true

	newActor.Parent = container

	table.insert(actors, newActor)
	
	_actors_modules_initialized[newActor] = {}
end

return function(module_script, ...)
	local actor : Actor = actors[actorIndex]
	actorIndex = actorIndex % actorCount + 1

	if not _actors_modules_initialized[actor][module_script] then
		actor:SendMessage("SandwichInit", module_script)
		actor.SandwichEnd.Event:Wait()

		_actors_modules_initialized[actor][module_script] = true
	end
	
	actor:SendMessage("SandwichStart", module_script, ...)
	actor.SandwichEnd.Event:Wait()
end