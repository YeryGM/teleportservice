local DEBUG_MODE = true

local LobbySelectors = require(script.Parent.Parent.store.lobby.LobbySelectors)
local useStoreSelector = require(script.Parent.useStoreSelector)

local useLobby = {}

function useLobby.useOpen()
	return useStoreSelector(LobbySelectors.selectOpen)
end

function useLobby.useDifficulty()
	return useStoreSelector(LobbySelectors.selectDifficulty)
end

function useLobby.useChapterSelected()
	return useStoreSelector(LobbySelectors.selectChapterSelected)
end

function useLobby.useChapters()
	return useStoreSelector(LobbySelectors.selectChapters)
end

if DEBUG_MODE then
	print("[useLobby] Hook cargado")
end

return useLobby
