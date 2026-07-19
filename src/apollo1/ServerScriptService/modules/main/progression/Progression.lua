local Checkpoint = require(script.Parent.Checkpoint)

local Progression = {
    checkpoints = {},
    globalIndex = 0,
    playerIndexes = {}
}

function Progression.getPlayerCheckpoint(player: Player)
    local playerCheckpoint = Progression.playerIndexes[player.UserId]
    if not playerCheckpoint then
        return Progression.checkpoints[Progression.globalIndex]
    else
        return Progression.checkpoints[playerCheckpoint]
    end
end

function Progression.getPlayerCheckpointCFrame(player: Player)
    local checkpoint = Progression.getPlayerCheckpoint(player)
    if checkpoint then
        return checkpoint.spawnCFrame
    end
    return nil
end

function Progression:load()
    --load and create checkpoints
    for _, checkpointPart in pairs(Checkpoint:getCheckPointInstances()) do
        local checkpoint = Checkpoint.new(checkpointPart, function(player: Player, checkpointId: number)
            self:updatePlayerCheckpoint(player, checkpointId)
        end)
        if not self.checkpoints[checkpoint.id] then
            self.checkpoints[checkpoint.id] = nil
        end
        self.checkpoints[checkpoint.id] = checkpoint
    end
end

function Progression:updatePlayerCheckpoint(player: Player, checkpointId: number)
    local checkpoint = self.checkpoints[checkpointId]
    if not checkpoint then
        if Checkpoint.debugOn then
            warn("Player " .. player.Name .. " hit checkpoint " .. checkpointId .. " but it does not exist")
        end
        return
    end
    -- means we already passed this checkpoint, so we ignore it
    if checkpointId > self.globalIndex then 
        if checkpoint.isGlobal then 
            self.globalIndex = checkpointId
            for userId, playerCheckpointId in pairs(self.playerIndexes) do
                if playerCheckpointId < checkpointId then
                    self.playerIndexes[userId] = checkpointId
                end
            end
        else
            self.playerIndexes[player.UserId] = checkpointId
        end
    else
        --this else is just for logs
        if Checkpoint.debugOn then
            warn("Player " .. player.Name .. " hit checkpoint " .. checkpointId .. " but is already at checkpoint " .. self.globalIndex)
        end
        return
    end
end

function Progression:unload()
    
end

return Progression