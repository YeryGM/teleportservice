local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)
local QteVal = require(script.Parent.Qte)

local RepeatedPressOk:RemoteFunction = ReplicatedStorage.funcs.general.player.RepeatedPressOk

local RepeatedPressVal = {
    playerMap = {}
}
RepeatedPressVal.__index = RepeatedPressVal
setmetatable(RepeatedPressVal, QteVal)

function RepeatedPressVal.new(player:Player, onSuccess, onFailure, configKey)
    local self = setmetatable(QteVal.new(player, onSuccess, onFailure, configKey), RepeatedPressVal)
    self.keys = self.config.keys or {}
    self.requiredPresses = self.config.requiredPresses or 10
    self.currentPresses = {}
    RepeatedPressVal.playerMap[player.UserId] = self
    self.event:Fire(player, Enums.qte.types.Repeated, self.data)
    return self
end

function RepeatedPressVal:validate(input)
    if self.keys[input.KeyCode] then
        self.currentPresses[input.KeyCode] = (self.currentPresses[input.KeyCode] or 0) + 1
        if self.currentPresses[input.KeyCode] >= self.requiredPresses then
            self.completed = true
            self.onSuccess()
        end
        return true
    else
        return false
    end
end

RepeatedPressOk.OnServerInvoke = function(player: Player, input)
    local validator = RepeatedPressVal.playerMap[player.UserId]
    if validator then
        return validator:validate(input)
    end
    return false
end

return RepeatedPressVal