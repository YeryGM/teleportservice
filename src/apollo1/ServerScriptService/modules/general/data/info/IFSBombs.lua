local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)

local IFSBombs = {
    [Enums.items.bombs.Stamina] = {
        name = "Stamina Bomb",
        amount = 1,
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        data = {
            duration = 5,
            radius = 25,
            damage = 0,
            fuseTime = 3,
            effectId = 123,
        },
    },
    [Enums.items.bombs.Speed] = {
        name = "Speed Bomb",
        amount = 1,
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        data = {
            duration = 5,
            radius = 25,
            damage = 0,
            fuseTime = 3,
            effectId = 123,
        },
    },
    [Enums.items.bombs.Smoke] = {
        name = "Smoke Bomb",
        amount = 1,
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        data = {
            duration = 5,
            radius = 25,
            damage = 0,
            fuseTime = 3,
            effectId = 123,
        },
    },
    [Enums.items.bombs.Slow] = {
        name = "Slow Bomb",
        amount = 1,
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        data = {
            duration = 5,
            radius = 25,
            damage = 0,
            fuseTime = 3,
            effectId = 123,
        },
    },
    [Enums.items.bombs.Random] = {
        name = "Random Bomb",
        amount = 1,
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        data = {
            duration = 5,
            radius = 25,
            damage = 0,
            fuseTime = 3,
            effectId = 123,
        },
    },
    [Enums.items.bombs.Poison] = {
        name = "Poison Bomb",
        amount = 1,
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        data = {
            duration = 5,
            radius = 25,
            damage = 0,
            fuseTime = 3,
            effectId = 123,
        },
    },
   
    [Enums.items.bombs.Jump] = {
        name = "Jump Bomb",
        amount = 1,
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        data = {
            duration = 5,
            radius = 25,
            damage = 0,
            fuseTime = 3,
            effectId = 123,
        },
    },
    [Enums.items.bombs.Health] = {
        name = "Health Bomb",
        amount = 1,
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        data = {
            duration = 5,
            radius = 25,
            damage = 0,
            fuseTime = 3,
            effectId = 123,
        },
    },
    [Enums.items.bombs.Freeze] = {
        name = "Freeze Bomb",
        amount = 1,
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        data = {
            duration = 5,
            radius = 25,
            damage = 0,
            fuseTime = 3,
            effectId = 123,
        },
    },
    [Enums.items.bombs.Death] = {
        name = "Death Bomb",
        amount = 1,
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        data = {
            duration = 5,
            radius = 25,
            damage = 0,
            fuseTime = 3,
            effectId = 123,
        },
    },
    [Enums.items.bombs.Distraction] = {
        name = "Distraction Bomb",
        amount = 1,
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        data = {
            duration = 5,
            radius = 25,
            damage = 0,
            fuseTime = 3,
            effectId = 123,
        },
    },

}

return IFSBombs