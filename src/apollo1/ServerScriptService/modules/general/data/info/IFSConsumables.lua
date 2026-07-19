local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)

local ConsumablesList = {
    [123344] = {
        data = {
            duration = 15,
            effectValue = 1.25
        },
        effects ={
            100,
            101,
        },
        name = ""
    },
    [123345] = {
        data = {
            duration = 15,
            effectValue = 0.30
        },
        effects = {
            102
        },
        name = ""

    },
    [123346] = {
        data = {
            duration = 15,
            effectValue = 1.25
        },
        effects = {
            103
        },
        name = ""
    },
    [123347] = {
        data = {
            duration = 15
        },
        effects = {
            104
        },
        name = ""
    },
    
}

return ConsumablesList