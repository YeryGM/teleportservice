local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)

local QteConfig = {
    [1] = {
        [Enums.npc.types.Breath] = {
            duration = 5,
            requiredPresses = 10,
            keys = {
                [Enum.KeyCode.E] = "E",
                [Enum.KeyCode.R] = "R",
                [Enum.KeyCode.Q] = "Q",
                [Enum.KeyCode.W] = "W",
            },
        },
    }
    

}
return QteConfig