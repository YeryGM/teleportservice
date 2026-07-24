local debugOn = true

local LobbySelectors = require(script.Parent.Parent.store.lobby.LobbySelectors)
local useStoreSelector = require(script.Parent.useStoreSelector)

local useLobby = {}

function useLobby.useOpen()
	return useStoreSelector(LobbySelectors.selectOpen)
end

function useLobby.useChapters()
	return useStoreSelector(LobbySelectors.selectChapters)
end

function useLobby.useChapterIndex()
	return useStoreSelector(LobbySelectors.selectChapterIndex)
end

function useLobby.useDifficultyIndex()
	return useStoreSelector(LobbySelectors.selectDifficultyIndex)
end

function useLobby.usePartySize()
	return useStoreSelector(LobbySelectors.selectPartySize)
end

if debugOn then
	print("[useLobby] Hook cargado")
end

return useLobby
