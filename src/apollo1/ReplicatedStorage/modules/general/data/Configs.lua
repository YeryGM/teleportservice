-- FOR CONFIGS OR INFO THAT DEPEND ON STATE like the diff
local Enums = require(script.Parent.Enums)
local State = require(script.Parent.State)
local configFolder = script.Parent.configs

local players = require(configFolder.Players)
local qtes = require(configFolder.Qtes)

local Configs = {
    [Enums.diff.Normal] = { 
        player = players[Enums.diff.Normal],
        qte = qtes[Enums.diff.Normal],
    },
    [Enums.diff.Nightmare] = { 
        player = players[Enums.diff.Nightmare],
        qte = qtes[Enums.diff.Nightmare],
    }
}

function Configs.getConfig()
    return Configs[State.getDifficulty()]
end


return Configs