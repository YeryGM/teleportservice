local DEBUG_MODE = true

local enumsFolder = script.Parent.enums

const Enums = {
    places = {
        cb = 1 
    },
    diff = {
        Normal = 1,
        Nightmare = 2,
    },
    platform = {
        PC = 1,
        Mobile = 2,
        Console = 3,
    },
    
    purchases = {
        shopTypes = {
            Prerun = 1,
            Vending = 2,
        },
    },
    player = {
        states = {
            Walk = 1,
            Run = 2,
            Crouch = 3,
            Attacked = 4,
            Hidden = 5,
            Minigame = 6,
            Hiding = 7,
        },
    },
    qte = {
        types = {
            Repeated = 1,
            Hold = 2,
            Sequence = 3,
        },
    },
    npc = {
        types = {
            Breath = 1,
        },
        actions = {
            Breath = {
                Qte = 1,
                Kill = 2,
                Cooldown = 3,
                Cutscene = 4,
            },
        }
    },
    zones = {
        Alleys = 1,
        Chocobank = 2,
        Chocofall = 3,
        Chocofountain = 4,
        MachineTwo = 5,
        Rainbowstairs = 6,
        Workers = 7,
        Lobby = 8,
        Rocket = 9,
        Milkway = 10,
        ShiningStars = 11,
        Tour = 12,
        Arcade = 13,
    },
    lobby = {
        state = {
            Libre = 1,
            Configurando = 2,
            Esperando = 3,
            Teleportando = 4,
        }
    },
    items = {
        types = {
            Consumable = 1,
            Bomb = 2,
        },
        bombs = {
            Stamina = 201,
            Speed = 202,
            Smoke = 203,
            Slow = 204,
            Random = 205,
            Poison = 206,
            Jump = 207,
            Health = 208,
            Freeze = 209,
            Death = 210,
            Distraction = 211,
        },
        consumables = {
            Stamina = 10,
            Speed = 123345,
            Strength = 123346,
            Defense = 123347,
        },
        effects = {
            Stamina = 301,
            Speed = 302,
            Smoke = 303,
            Slow = 304,
            Random = 305,
            Poison = 306,
            Jump = 307,
            Health = 308,
            Freeze = 309,
            Death = 310,
        },
    },
    furniture = {
        Closet = 1,
    },
    device = {
        types = {
            PC = 1,
            Mobile = 2,
        },
    },
    story = {
        objectives = {
            states = {
                incomplete = 1,
                inProgress = 2,
                complete = 3,
            },
            actions = {
                show = 1,
                subShow = 2,
                complete = 3,
                subComplete = 4,
            }
        },
        dialogues = require(enumsFolder.EDialogues),
    },
    format = {
        
    },
}

if DEBUG_MODE then
    print("[Enums] LobbyState y Difficulty cargados")
end

return Enums