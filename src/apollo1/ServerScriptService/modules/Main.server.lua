local Signals = require(script.Parent.general.data.Signals)
local LobbyManager = require(script.Parent.main.lobby.LobbyManager)

Signals.create()
LobbyManager:load()
