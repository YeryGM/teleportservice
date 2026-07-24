local debugOn = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)

local LobbyState = {}

function LobbyState.createInitialState()
	return {
		isOpen = false,
		chapters = {},
		chapterIndex = 1,
		difficultyIndex = 1,
		partySize = 1,
	}
end

if debugOn then
	print("[LobbyState] Estado inicial creado")
end

return LobbyState
