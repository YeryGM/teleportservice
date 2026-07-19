local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ZoneDetector = require(script.Parent.ZoneDetector)
local ModuleLoader = require(script.Parent.ModuleLoader)
local State = require(ReplicatedStorage.modules.general.data.State)

local Schemer = {}

function Schemer:load()
    local loadedState = nil -- FROM MEMORY STORE
    self:setState(loadedState)
    ZoneDetector:load()
    ZoneDetector:SetCallback(function(previousZone, newZone, player)
        ModuleLoader.loadZone(previousZone, newZone, player)
    end)
    ModuleLoader.init()
    --CARGAR ITEMS
end

function Schemer:setState(_loadedState)
    State.setDifficulty(1)
end

return Schemer
