local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reflex = require(ReplicatedStorage.packages.Reflex)

local LobbyProducer = require(script.Parent.lobby.LobbyProducer)

local RootProducer = Reflex.combineProducers({
    lobby = LobbyProducer,
})

return RootProducer
