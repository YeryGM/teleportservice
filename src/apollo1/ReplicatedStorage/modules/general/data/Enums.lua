local debugOn = true

local Enums = {
    places = {
        cb = 1
    },
    diff = {
        Normal = 1,
        Nightmare = 2,
        COUNT = 2,
    },
    platform = {
        PC = 1,
        Mobile = 2,
        Console = 3,
    },
    lobby = {
        state = {
            Libre = 1,
            Configurando = 2,
            Esperando = 3,
            Teleportando = 4,
        }
    },
}

if debugOn then
    print("[Enums] LobbyState y Difficulty cargados")
end

return Enums
