local Enums = require(script.Parent.Parent.Enums)

local BombList = {
    [Enums.items.bombs.Slow] = {
        name = "Slow Bomb",
        description = "Greatly reduces the speed of players in the area",
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        assetId = "rbxassetid://123",
        config = {
            MaxChargeTime = 3,
            Speed = 50,
            Gravity = Vector3.new(0, -workspace.Gravity, 0),
            Lifetime = 5,
            TrajectoryVisible = true,
        },
    },
    [Enums.items.bombs.Speed] = {
        name = "Speed Bomb",
        description = "Greatly increases the speed of players in the area",
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        assetId = "rbxassetid://123",
        config = {
            MaxChargeTime = 3,
            Speed = 100,
            Gravity = Vector3.new(0, -workspace.Gravity, 0),
            Lifetime = 5,
            TrajectoryVisible = true,
        },
    },
    [Enums.items.bombs.Poison] = {
        name = "Poison Bomb",
        description = "Poisons players in the area, dealing damage over time",
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        assetId = "rbxassetid://123",
        config = {
            MaxChargeTime = 3,
            DamagePerSecond = 10,
            Gravity = Vector3.new(0, -workspace.Gravity, 0),
            Lifetime = 5,
            TrajectoryVisible = true,
        },
    },
    [Enums.items.bombs.Jump] = {
        name = "Jump Bomb",
        description = "Greatly increases the jump power of players in the area",
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        assetId = "rbxassetid://123",
        config = {
            MaxChargeTime = 3,
            JumpPowerIncrease = 50,
            Gravity = Vector3.new(0, -workspace.Gravity, 0),
            Lifetime = 5,
            TrajectoryVisible = true,
        },
    },
    [Enums.items.bombs.Health] = {
        name = "Health Bomb",
        description = "Heals players in the area over time",
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        assetId = "rbxassetid://123",
        config = {
            MaxChargeTime = 3,
            HealPerSecond = 10,
            Gravity = Vector3.new(0, -workspace.Gravity, 0),
            Lifetime = 5,
            TrajectoryVisible = true,
        },
    },
    [Enums.items.bombs.Random] = {
        name = "Random Bomb",
        description = "Applies a random effect to players in the area",
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        assetId = "rbxassetid://123",
        config = {
            MaxChargeTime = 3,
            Gravity = Vector3.new(0, -workspace.Gravity, 0),
            Lifetime = 5,
            TrajectoryVisible = true,
        },
    },
    [Enums.items.bombs.Smoke] = {
        name = "Smoke Bomb",
        description = "Creates a smoke cloud that obscures vision and silences players in the area",
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        assetId = "rbxassetid://123",
        config = {
            MaxChargeTime = 3,
            SmokeDuration = 5,
            Gravity = Vector3.new(0, -workspace.Gravity, 0),
            Lifetime = 5,
            TrajectoryVisible = true,
        },
    },
    [Enums.items.bombs.Freeze] = {
        name = "Freeze Bomb",
        description = "Freezes players in the area, preventing movement and actions",
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        assetId = "rbxassetid://123",
        config = {
            MaxChargeTime = 3,
            FreezeDuration = 5,
            Gravity = Vector3.new(0, -workspace.Gravity, 0),
            Lifetime = 5,
            TrajectoryVisible = true,
        },
    },
    [Enums.items.bombs.Death] = {
        name = "Death Bomb",
        description = "Instantly eliminates players in the area",
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        assetId = "rbxassetid://123",
        config = {
            MaxChargeTime = 3,
            Gravity = Vector3.new(0, -workspace.Gravity, 0),
            Lifetime = 5,
            TrajectoryVisible = true,
        },
    },
    [Enums.items.bombs.Distraction] = {
        name = "Distraction Bomb",
        description = "Distracts players in the area, making them vulnerable to attacks",
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        assetId = "rbxassetid://123",
        config = {
            MaxChargeTime = 3,
            DistractionDuration = 5,
            Gravity = Vector3.new(0, -workspace.Gravity, 0),
            Lifetime = 5,
            TrajectoryVisible = true,
        },
    },
    [Enums.items.bombs.Stamina] = {
        name = "Stamina Bomb",
        description = "Reduces the stamina of players in the area, preventing them from sprinting or performing certain actions",
        recipe = {
            [0] = {amount = 1},
            [1] = {amount = 1},
        },
        assetId = "rbxassetid://123",
        config = {
            MaxChargeTime = 3,
            StaminaReductionDuration = 5,
            Gravity = Vector3.new(0, -workspace.Gravity, 0),
            Lifetime = 5,
            TrajectoryVisible = true,
        },
    },
}
return BombList