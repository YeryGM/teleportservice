local ReplicatedStorage = game:GetService("ReplicatedStorage")

local playerRemotes = ReplicatedStorage.events.general.player
local waitingFinishedEvent: RemoteEvent = playerRemotes.waitingFinished
local playerCountUpdateEvent: RemoteEvent = playerRemotes.playerCountUpdate

local Waiting = {
    waiters = {},
    playerCount = 0,
    waitingCount = 0,
    actualWait = 0
}

local function onCountUpdate()
    playerCountUpdateEvent:FireAllClients(Waiting.playerCount, Waiting.waitingCount)
end

function Waiting:loadPlayer(player:Player)
    if not self.waiters[player.UserId] then
        self.waiters[player.UserId] = false
        self.playerCount = self.playerCount + 1
        onCountUpdate()
    end
end

function Waiting:unloadPlayer(player:Player)
    if self.waiters[player.UserId] then
        self.waiters[player.UserId] = nil
        if self.playerCount > 0 then
            self.playerCount = self.playerCount - 1
        end
        onCountUpdate()
    end
end

function Waiting:registerWaitingPlayer(player:Player)
    if not self.waiters[player.UserId] then
        self.waiters[player.UserId] = true
        if self.waitingCount > 0 then
            self.waitingCount = self.waitingCount - 1
        else
            self:finish()
        end
        onCountUpdate()
    end
end

function Waiting:unregisterWaitingPlayer(player:Player)
    if self.waiters[player.UserId] then
        self.waiters[player.UserId] = nil
        self.waitingCount = self.waitingCount + 1
        onCountUpdate()
    end
end

function Waiting:finish()
    self.waiters = {}
    self.waitingCount = 0
    waitingFinishedEvent:FireAllClients()
    self.actualWait += 1
end

return Waiting