local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Configs = require(ReplicatedStorage.modules.general.data.Configs)

local qteEvent:RemoteEvent = ReplicatedStorage.events.general.player.qte

local QteVal = {}
QteVal.__index = QteVal

function QteVal.new(player:Player, onSuccess, onFailure, configKey)
    local self = setmetatable({}, QteVal)
    local configs = Configs.getConfig().qte
    local config = configs[configKey]
    if not config then
        warn("Invalid QTE config key: " .. tostring(configKey))
        return nil
    end
    self.config = config
    self.player = player
    self.onSuccess = onSuccess
    self.onFailure = onFailure
    self.completed = false
    self.event = qteEvent
    self.conns = {}
    self.duration = config.duration or 5
    local now = Workspace:GetServerTimeNow()
    self.data = {
        configKey = configKey,
        startTime = now,
        serverTime = now,
    }
    task.delay(self.duration, function()
        if not self.completed and self.onFailure then
            self:onFailure()
        end
        if self.unload then
            self:unload()
        end
    end)
    return self
end

return QteVal