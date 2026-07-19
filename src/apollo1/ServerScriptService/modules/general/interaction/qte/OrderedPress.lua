local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)
local QteVal = require(script.Parent.Qte)

local OrderedPressOk: RemoteFunction = ReplicatedStorage.funcs.general.player.OrderedPressOk

local OrderedPressVal = {
    playerMap = {}
}
OrderedPressVal.__index = OrderedPressVal
setmetatable(OrderedPressVal, QteVal)

function OrderedPressVal.new(player:Player, onSuccess, onFailure, configKey)
    local self = setmetatable(QteVal.new(player, onSuccess, onFailure, configKey), OrderedPressVal)
    self.sequence = self.config.sequence 
    self.retryOnFailure = self.config.retryOnFailure or false
    self.currentIndex = 1
    OrderedPressVal.playerMap[player.UserId] = self
    self.event:Fire(player, Enums.qte.types.Sequence, self.data)
    return self
end

-- keyCode is the KeyCode enum value sent directly from the client
function OrderedPressVal:validate(keyCode:Enum.KeyCode)
    local expected = self.sequence[self.currentIndex]
    local progressPercent = (self.currentIndex - 1) / #self.sequence
    if expected and keyCode == expected then
        self.currentIndex += 1
        if self.currentIndex > #self.sequence then
            self.completed = true
            self.onSuccess()
        end
        return true, progressPercent
    else
        if self.retryOnFailure then
            -- wrong key: reset back to the start of the sequence
            -- stay on the same index to retry the current key
            self.currentIndex = 1
            return false, progressPercent
        else
            self.completed = true
            self.onFailure()
            return false, progressPercent
        end
    end
end

OrderedPressOk.OnServerInvoke = function(player: Player, keyCode: Enum.KeyCode)
    local validator = OrderedPressVal.playerMap[player.UserId]
    if validator then
        return validator:validate(keyCode)
    end
    return false, 0
end

return OrderedPressVal