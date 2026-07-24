local debugOn = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)

local LobbyState = {}

function LobbyState.createInitialState()
	return {
		isOpen = false,
		chapters = {},
		chapterSelected = nil,
		difficulty = Enums.diff.Normal,
	}
end

if debugOn then
	print("[LobbyState] Estado inicial creado")
end

return LobbyState
