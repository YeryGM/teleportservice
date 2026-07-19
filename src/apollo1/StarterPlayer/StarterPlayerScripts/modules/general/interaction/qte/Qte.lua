local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Configs = require(ReplicatedStorage.modules.general.data.Configs)
local UISQte = require(script.Parent.Parent.Parent.Parent.ui.services.UISQte) 

local Qte = {}
Qte.__index = Qte

function Qte.new(onSuccess, onFailure, data, qteEnum)
    local configs = Configs.getConfig().qte
    local configKey = data and data.configKey
    local config = configs[configKey]
    if not config then
        warn("Invalid QTE config key: " .. tostring(configKey))
        return nil
    end

    local startTime = data and (data.startTime or data.serverTime) or 0
    local delayed = Workspace:GetServerTimeNow() - startTime
    local self = setmetatable({}, Qte)
    self.duration = math.max(0, config.duration - delayed)
    self.completed = false
    self.config = config
    self.configKey = configKey
    self.conns = {}

    self.onSuccess = function()
        if not self:stop() then return end
        if onSuccess then
            onSuccess()
        end
    end
    self.onFailure = function()
        if not self:stop() then return end
        if onFailure then
            onFailure()
        end
    end
    UISQte.setQte(qteEnum)
    self.thread = task.delay(self.duration, function()
        if not self.completed and onFailure then
            self:onFailure()
        end
    end)
    return self
end

function Qte:stop()
    if self.thread and coroutine.status(self.thread) ~= "dead" then
        task.cancel(self.thread)
        self.thread = nil
    end
    if not self.completed then
        self.completed = true
        UISQte.setQte(nil)
        if self.unload then
            self:unload()
        end
        return true
    end
    return false
end

return Qte