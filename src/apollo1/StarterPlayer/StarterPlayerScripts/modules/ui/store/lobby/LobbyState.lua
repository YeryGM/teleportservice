local DEBUG_MODE = true

local LobbyState = {}

function LobbyState.createInitialState()
	return {
		isOpen = false,
		chapters = {},
		chapterSelected = nil,
		difficulty = 2,
	}
end

if DEBUG_MODE then
	print("[LobbyState] Estado inicial creado")
end

return LobbyState
