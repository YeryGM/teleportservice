local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Spectating = require(script.Parent.Spectating)

local mainFolder = ServerScriptService.modules.main
local Progression = require(mainFolder.progression.Progression)
local Caller = require(mainFolder.purchases.Caller)

local config = {
    reviveId = 17390923, 
    data = {
        amount = 1,
    }
}

local Revive = {
    reviveOnDeath = true,
    debugOn = false,
    conns = {},
    playerConns = {},
    deathConns = {},
    deadPlayers = {},
    lastRequest = {},
    timeBetweenRequests = 0.6,
    timeBeforeDisableAutoRevive = 10,
}

local function verifyPlayer(player: Player)
    if not player then
        return false
    end
    if not player:IsA("Player") then
        if Revive.debugOn then
            warn("Expected Player instance, got", typeof(player))
        end
        return false
    end
    return true
end

function Revive:setReviveOnDeath(value: boolean)
    assert(type(value) == "boolean", "Value must be a boolean")
    self.reviveOnDeath = value
end

function Revive:canRevive(player: Player)
    if not self.reviveOnDeath then
        return false
    end
    if not self.deadPlayers[player.UserId] then
        return false
    end
    if not Spectating:areThereAlivePlayers() then
        return false
    end
    local now = os.clock()
    local last = self.lastRequest[player.UserId]
    if last and now - last < self.timeBetweenRequests then
        return false
    end
    self.lastRequest[player.UserId] = now
    return true
end

function Revive:requestRevive(player: Player)
    if not verifyPlayer(player) then
        return false
    end
    local canRevive = self:canRevive(player)
    if not canRevive then
        return false
    end
    local ok, result = pcall(function()
        return Caller.processItemPurchase(player, config.reviveId, config.data)
    end)
    if not ok or not result then
        if self.debugOn then
            warn("Failed to process revive purchase for", player.Name, "with error:", result)
        end
        return false
    end
    return true
end

function Revive:revivePlayer(player: Player)
    if not verifyPlayer(player) then
        return false
    end
    local isPlayerDead = self.deadPlayers[player.UserId]
    if not isPlayerDead then
        return false
    end
    
    self.deadPlayers[player.UserId] = false
    local ok = pcall(function()
        player:LoadCharacterAsync()
    end)
    if not ok then
       --retry once after short delay in case of failure
        while not player.Character do
            task.wait(0.5)
            local success = pcall(function()
                player:LoadCharacterAsync()
            end)
            if success and player.Character then
                break
            end
        end
    end
    Spectating:stopSpectating(player)
    Spectating:clearWaiting(player)
    
    local spawnCFrame = Progression.getPlayerCheckpointCFrame(player)
    if spawnCFrame then
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
        if humanoidRootPart then
            humanoidRootPart.CFrame = spawnCFrame
        elseif self.debugOn then
            warn("Revive: HumanoidRootPart missing for " .. player.Name)
        end
    elseif self.debugOn then
        warn("Revive: No checkpoint found for " .. player.Name)
    end
    return true 
end

function Revive:onPlayerDied(player: Player)
    if not verifyPlayer(player) then
        return
    end
    local userId = player.UserId
    if self.deadPlayers[userId] then
        return
    end
     self.deadPlayers[userId] = true
    Spectating:markDead(player)
    local canRevive = self:canRevive(player)
    if not canRevive then
        Spectating:startSpectating(player)
    else
        self:revivePlayer(player)
    end
end


-- LOAD/UNLOAD
--CHARACTER
function Revive:loadCharacter(player: Player)
    if not verifyPlayer(player) or not player.Character then
        return 
    end
    self.deadPlayers[player.UserId] = false
    Spectating:markAlive(player)
    Spectating:stopSpectating(player)
end

function Revive:unloadCharacter(_player: Player)
    -- will use the humanoid died event to mark player as dead, so no need to do anything here
end
---PLAYER
function Revive:loadPlayer(_player: Player)
    --the player is loaded with the character
end

function Revive:unloadPlayer(player: Player)
    local userId = player.UserId
    self.deadPlayers[userId] = nil
    self.lastRequest[userId] = nil
    Spectating:removePlayer(player)
end
--SERVICE
function Revive:load()
    task.delay(self.timeBeforeDisableAutoRevive,
        function()
            Players.CharacterAutoLoads = false
    end)
end

function Revive:unload()
    for _, conn in ipairs(self.conns) do
        conn:Disconnect()
    end
    self.conns = {}
    self.deadPlayers = {}
    self.lastRequest = {}
    Players.CharacterAutoLoads = true
end

return Revive