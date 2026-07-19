local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.modules.general.data.State)

local ZoneDetector = require(script.Parent.ZoneDetectorC)
local ModuleLoader = require(script.Parent.ModuleLoaderC)
local DeviceDetector = require(script.Parent.DeviceDetector)


local Schemer = {}

function Schemer:load()
    local loadedState = nil -- FROM MEMORY STORE
    self:setState(loadedState)
    ZoneDetector:load()
    ZoneDetector:SetCallback(function(previousZone, newZone)
        ModuleLoader.loadZone(previousZone, newZone)
    end)
    ModuleLoader.init()
end

function Schemer:setState(_loadedState)
    State.setDifficulty(1)
    State.setDevice(DeviceDetector:getPlatformInfo())
end

return Schemer
