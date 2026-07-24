local debugOn = true

local LobbySelectors = {}

function LobbySelectors.selectOpen(state)
	return state.lobby.isOpen
end

function LobbySelectors.selectChapters(state)
	return state.lobby.chapters
end

function LobbySelectors.selectChapterIndex(state)
	return state.lobby.chapterIndex
end

function LobbySelectors.selectDifficultyIndex(state)
	return state.lobby.difficultyIndex
end

function LobbySelectors.selectPartySize(state)
	return state.lobby.partySize
end

if debugOn then
	print("[LobbySelectors] Selectores cargados")
end

return LobbySelectors
