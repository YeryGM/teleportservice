local DEBUG_MODE = true

local LobbySelectors = {}

function LobbySelectors.selectOpen(state)
	return state.lobby.isOpen
end

function LobbySelectors.selectDifficulty(state)
	return state.lobby.difficulty
end

function LobbySelectors.selectChapterSelected(state)
	return state.lobby.chapterSelected
end

function LobbySelectors.selectChapters(state)
	return state.lobby.chapters
end

if DEBUG_MODE then
	print("[LobbySelectors] Selectores cargados")
end

return LobbySelectors
