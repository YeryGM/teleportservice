--[[  
	playerModules do .new() they self:load(), need to unload from here, as they might be called 
		after player spawn, respawn need safe guards
	serviceModules need loadPlayer/unloadPlayer and loadCharacter/unloadCharacter 
]]

local playerServices = script.Parent.services
local Reviving = require(playerServices.Reviving)
local Spectating = require(playerServices.Spectating)
local Waiting = require(playerServices.Waiting)
local Hiding = require(playerServices.Hiding)

local playerModules = script.Parent.submod
local Stamina = require(playerModules.Stamina)
local Effects = require(playerModules.Effects)
local Tools = require(playerModules.Tools)
local Overview = require(playerModules.Overview)

local Player = {
	debugOn = false,
	states = {
		NotHiding = 0,
		JustHid = 1,
		Hiding = 2,
	},
}
Player.__index = Player

local function cleanUpConns(conns)
	for _, conn in ipairs(conns) do
		if conn and conn.Connected then
			conn:Disconnect()
		end
	end
	table.clear(conns)
end

function Player.new(player:Player)
	local self = setmetatable({}, Player)
	self.player = player
	self.handlers = {
		stamina = Stamina.new(player),
		effects = Effects.new(player),
		tools = Tools.new(player),
		overview = Overview.new(player),
	}
	self.serviceHandlers = {
		hiding = Hiding,
		spectating = Spectating,
		waiting = Waiting,
		reviving = Reviving,
	}
	self.conns = {}
	self.characterConns = {}
	self.characterLoaded = false
	self.playerLoaded = false
	self:load()
	return self
end

function Player:load()
	if self.playerLoaded then
		if self.debugOn then
			print("Player already loaded for", self.player.Name)
		end
		return
	end
	self.playerLoaded = true
	local characterAddedConn = self.player.CharacterAdded:Connect(function(character)
		self:loadCharacter(character)
	end)
	table.insert(self.conns, characterAddedConn)

	local characterRemovingConn = self.player.CharacterRemoving:Connect(function()
		self:unloadCharacter()
	end)
	table.insert(self.conns, characterRemovingConn)
	--handlers load themselves on new 
	--services need loadPlayer called on them
	for _, service in pairs(self.serviceHandlers) do
		if service.loadPlayer then
			service:loadPlayer(self.player)
		end
	end

	local character = self.player.Character
	if character then
		self:loadCharacter(character)
	end
end

function Player:unload()
	if not self.playerLoaded then
		if self.debugOn then
			print("Player not loaded for", self.player.Name)
		end
		return
	end
	cleanUpConns(self.conns)
	self.conns = {}
	for _, handler in pairs(self.handlers) do
		if handler.unload then
			handler:unload()
		end
	end
	for _, service in pairs(self.serviceHandlers) do
		if service.unloadPlayer then
			service:unloadPlayer(self.player)
		end
	end
	self:unloadCharacter()
	self.playerLoaded = false
end

--CHARACTER
function Player:loadCharacter(character)
	if self.characterLoaded then
		if self.debugOn then
			print("Character already loaded for", self.player.Name)
		end
		return
	end
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		if self.debugOn then
			print("Humanoid missing for", self.player.Name)
		end
		return
	end
	self.characterLoaded = true
	local diedConn = humanoid.Died:Connect(function()
		self:onHumanoidDied()
	end)
	table.insert(self.characterConns, diedConn)

	for _, handler in pairs(self.handlers) do
		if handler.loadCharacter then
			handler:loadCharacter()
		end
	end

	for _, service in pairs(self.serviceHandlers) do
		if service.loadCharacter then
			service:loadCharacter(self.player)
		end
	end
end

function Player:unloadCharacter()
	if not self.characterLoaded then
		if self.debugOn then
			print("Character not loaded for", self.player.Name)
		end
		return
	end
	cleanUpConns(self.characterConns)
	for _, handler in pairs(self.handlers) do
		if handler.unload then
			handler:unload()
		end
	end
	for _, service in pairs(self.serviceHandlers) do
		if service.unloadCharacter then
			service:unloadCharacter(self.player)
		end
	end
	
	self.characterLoaded = false
end

function Player:onHumanoidDied()
	Hiding:unhide(self.player)
	Spectating:markDead(self.player)
	Reviving:onPlayerDied(self.player)
end

function Player:takeDamage(damage:number)
	local character = self.player.Character
	if character and character:FindFirstChild("Humanoid") then
		character.Humanoid:TakeDamage(damage)
	end
end
--STAMINA
function Player:handleStamina(deltaTime:number)
	self.handlers.stamina:handleStamina(deltaTime)
end

function Player:onUseStamina(shouldDrain:boolean)
	self.handlers.stamina:onUse(shouldDrain)
end

function Player:getCurrentStamina():number
	return self.handlers.stamina:getCurrentStamina()
end

function Player:modifyStamina(isApplying:boolean, maxStamina:number, regenRate:number, drainRate:number)
	return self.handlers.stamina:onModify(isApplying, maxStamina, regenRate, drainRate)
end

function Player:setShouldCheck(shouldEnable:boolean)
	self.handlers.stamina:setShouldCheck(shouldEnable)
end

--OVERVIEW
function Player:getOverview()
	return self.handlers.overview:getOverview()
end
--EFFECTS
function Player:applyEffect(effectId:number, data)
	self.handlers.effects:applyEffect(effectId, data)
end

return Player
