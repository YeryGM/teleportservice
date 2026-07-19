local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)
local State = require(ReplicatedStorage.modules.general.data.State)
local configFolder = script.Parent.configs

local Npcs = require(configFolder.Npcs)

local Configs = {
    [Enums.diff.Normal] = { 
        npc = Npcs[Enums.diff.Normal],
        
    },
    [Enums.diff.Nightmare] = { 
        npc = Npcs[Enums.diff.Nightmare],
    }
}

function Configs.getConfig()
    return Configs[State.getDifficulty()]
end


return Configs