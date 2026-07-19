local ReplicatedStorage = game:GetService("ReplicatedStorage")
local generalFolder = script.Parent.Parent.Parent
local Enums = require(ReplicatedStorage.modules.general.data.Enums)

local ProximityPrompts = {
    general = {
        player = require(generalFolder.player.PPPlayer),
    },
    zones = {
        [Enums.zones.Chocobank] = nil,
    },
}
return ProximityPrompts