local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local Player = require(script.Parent.Player)

local playerServices = script.Parent.services
local Hiding = require(playerServices.Hiding)
--local Spectating = require(playerServices.Spectating)
local Waiting = require(playerServices.Waiting)
local Reviving = require(playerServices.Reviving)

local bindableFunc = ServerScriptService.funcs.general.player
local damagePlayer: BindableFunction = bindableFunc.damagePlayer
local revivePlayer: BindableFunction = bindableFunc.revivePlayer
local canPlayerRevive: BindableFunction = bindableFunc.canPlayerRevive
local modifyStamina: BindableFunction = bindableFunc.modifyStamina

local remoteFunc = ReplicatedStorage.funcs.general.player
local requestReviveFunc: RemoteFunction = remoteFunc.requestRevive
local useStamina: RemoteFunction = remoteFunc.useStamina
local requestOverview:RemoteFunction = remoteFunc.requestOverview

local remoteEvent = ReplicatedStorage.events.general.player
local hideEvent:RemoteEvent = remoteEvent.hide
local returnToLobbyEvent: RemoteEvent = remoteEvent.returnToLobby
local playAgainEvent: RemoteEvent = remoteEvent.playAgain
local registerWaitingEvent: RemoteEvent = remoteEvent.registerWaiting

local bindableEvent = ServerScriptService.events.general.player
local applyEffects: BindableEvent = bindableEvent.applyEffects
local applyEffect: BindableEvent = bindableEvent.applyEffect

local PlayerManager = {
    debugOn = false,
    conns = {
	},
	playerMap = {},
}

local function getPlayer(userId:number)
    local player = PlayerManager.playerMap[userId]
    if not player then
        if PlayerManager.debugOn then
            warn("Player with userId " .. tostring(userId) .. " not found in playerMap")
        end
        return nil
    end
    return player
end

function PlayerManager:load()
    --PLAYER ADDED/REMOVED
	local conn = Players.PlayerRemoving:Connect(function(player: Player)
		self:unloadPlayer(player)
	end)
	table.insert(self.conns, conn)
	local conn2 = Players.PlayerAdded:Connect(function(player: Player)
		self:loadPlayer(player)
	end)
	table.insert(self.conns, conn2)

    --ROBLOX SERVICES EVENTS
    local conn3 = RunService.Heartbeat:Connect(function(deltaTime)
        for _, player in pairs(self.playerMap) do
            player:handleStamina(deltaTime)
        end
    end)
    table.insert(self.conns, conn3)
    
    --PLAYER SERVICES EVENTS
    --HIDING
    local conn4 = hideEvent.OnServerEvent:Connect(function(player: Player, data)
        PlayerManager.unhidePlayer(player, data)
    end)
    table.insert(self.conns, conn4)
    --DAMAGE
	damagePlayer.OnInvoke = function(userId:number, damage:number)
		local playerInstance = getPlayer(userId)
		if not playerInstance then return end
		playerInstance:takeDamage(damage)
	end
    --REVIVING
    requestReviveFunc.OnServerInvoke = function(player: Player)
        return PlayerManager.requestRevive(player)
    end
    canPlayerRevive.OnInvoke = function(UserId:number)
        return PlayerManager.canRevive(UserId)
    end
    revivePlayer.OnInvoke = function(userId:number)
        return PlayerManager.revive(userId)
    end
    --WAITING
    registerWaitingEvent.OnServerEvent:Connect(function(player: Player)
        PlayerManager.registerWaitingPlayer(player)
    end)

    -- PLAYER SUBMODULES EVENTS
    --STAMINA
    useStamina.OnServerInvoke = function(player: Player, shouldDrain:boolean)
        local playerInstance = getPlayer(player.UserId)
        if not playerInstance then return end
        return playerInstance:onUseStamina(shouldDrain)
    end
    modifyStamina.OnInvoke = function(player: Player, isApplying:boolean, maxStamina:number, regenRate:number, drainRate:number)
        local playerInstance = getPlayer(player.UserId)
        if not playerInstance then return end
        return playerInstance:modifyStamina(isApplying, maxStamina, regenRate, drainRate)
    end
    --TELEPORT
    local returnConn = returnToLobbyEvent.OnServerEvent:Connect(function(player: Player)
        local playerInstance = getPlayer(player.UserId)
        if not playerInstance then return end
        -- TO DO WHEN TELEPORT IS IMPLEMENTED
    end)
    table.insert(self.conns, returnConn)

    local playAgainConn = playAgainEvent.OnServerEvent:Connect(function(player: Player)
        local playerInstance = getPlayer(player.UserId)
        if not playerInstance then return end
        playerInstance:playAgain()
        -- TO DO WHEN TELEPORT IS IMPLEMENTED
    end)
    table.insert(self.conns, playAgainConn)

    --  EFFECTS
    local conn5 = applyEffects.Event:Connect(function(players: {Player}, effectId:number, data)
        PlayerManager.applyEffects(players, effectId, data)
    end)
    table.insert(self.conns, conn5)
    local conn6 = applyEffect.Event:Connect(function(player: Player, effectId:number, data)
        PlayerManager.applyEffect(player, effectId, data)
    end)
    table.insert(self.conns, conn6)

    --PLAYER OVERVIEW
    requestOverview.OnServerInvoke = function(player: Player)
        local playerInstance = getPlayer(player.UserId)
        if not playerInstance then return end
        return playerInstance:getOverview()
    end
    --load all (even though PlayerAdded should fire for them, this ensures they are loaded before any events try to access them)
	for _, player in ipairs(Players:GetPlayers()) do
		self:loadPlayer(player)
	end
end

function PlayerManager:loadPlayer(player:Player)
    local playerInstance = getPlayer(player.UserId)
    if not playerInstance then
        self.playerMap[player.UserId] = Player.new(player)
    else 
        if self.debugOn then
            print("Player already created:", player.Name)
        end
        playerInstance:load()
    end
end

function PlayerManager:unloadPlayer(player:Player)
    local playerInstance = getPlayer(player.UserId)
    if playerInstance then
        playerInstance:unload()
        self.playerMap[player.UserId] = nil
    end
end

function PlayerManager:unload()
	for _, conn in ipairs(self.conns) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
	end
	table.clear(self.conns)
    for _, playerInstance in pairs(self.playerMap) do
        playerInstance:unload()
    end
end

-- STAMINA
function PlayerManager.toggleStamina(player: Player, shouldEnable: boolean)
    local playerInstance = getPlayer(player.UserId)
    if not playerInstance then return end
    return playerInstance:toggleStamina(shouldEnable)
end
-- EFFECTS
function PlayerManager.applyEffect(player: Player, effectId:number, data)
    local playerInstance = getPlayer(player.UserId)
    if not playerInstance then return end
    return playerInstance:applyEffect(effectId, data)
end

function PlayerManager.applyEffects(players: {Player}, effectId:number, data)
    for _, player in pairs(players) do
        PlayerManager.applyEffect(player, effectId, data)
    end
end

-- PLAYER SERVICES 
--HIDING
function PlayerManager.hidePlayer(interactedObject:BasePart, player:Player, prompt:ProximityPrompt)
    if not interactedObject or not player or not prompt then return end
    if not interactedObject.Parent or not interactedObject.Parent:IsA("Model") then return end
    if not prompt:IsA("ProximityPrompt") then return end

    local hidingSpot = interactedObject.Parent
    if not interactedObject:IsDescendantOf(hidingSpot) then return end
    if not prompt:IsDescendantOf(hidingSpot) then return end
    if not prompt.Enabled then return end

    local playerInstance = getPlayer(player.UserId)
    if not playerInstance then return end
    return Hiding:hide(player, prompt, hidingSpot)
end

function PlayerManager.unhidePlayer(player:Player, data)
    if typeof(data) ~= "table" then return end
    local playerInstance = getPlayer(player.UserId)
    if not playerInstance then return end
    if data.shouldHide ~= false then return end -- client cant initiate hiding, only unhiding
    return Hiding:unhide(player)
end
-- REVIVING
function PlayerManager.requestRevive(player:Player)
    local playerInstance = getPlayer(player.UserId)
    if not playerInstance then return false end
	return Reviving:requestRevive(playerInstance.player)
end

function PlayerManager.canRevive(userId:number)
    local playerInstance = getPlayer(userId)
    if not playerInstance then return false end
	return Reviving:canRevive(playerInstance.player)
end

function PlayerManager.revive(userId:number)
    local playerInstance = getPlayer(userId)
    if not playerInstance then return false end
	return Reviving:revivePlayer(playerInstance.player)
end

--WAITING
function PlayerManager.registerWaitingPlayer(player:Player)
    local playerInstance = getPlayer(player.UserId)
    if not playerInstance then return end
    return Waiting:registerWaitingPlayer(player)
end

return PlayerManager