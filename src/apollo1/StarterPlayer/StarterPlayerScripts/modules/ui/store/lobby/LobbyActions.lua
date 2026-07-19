local DEBUG_MODE = true

local RootStore = require(script.Parent.Parent.RootStore)

local LobbyActions = {}

function LobbyActions.getState()
	return RootStore.producer:getState().lobby
end

function LobbyActions.openLobby()
	if DEBUG_MODE then
		print("[LobbyActions] openLobby")
	end
	RootStore.producer.lobby.openLobby()
end

function LobbyActions.closeLobby()
	if DEBUG_MODE then
		print("[LobbyActions] closeLobby")
	end
	RootStore.producer.lobby.closeLobby()
end

function LobbyActions.setDifficulty(difficulty: number)
	if DEBUG_MODE then
		print("[LobbyActions] setDifficulty: " .. tostring(difficulty))
	end
	RootStore.producer.lobby.setDifficulty(difficulty)
end

function LobbyActions.setChapter(chapter: string)
	if DEBUG_MODE then
		print("[LobbyActions] setChapter: " .. chapter)
	end
	RootStore.producer.lobby.setChapter(chapter)
end

function LobbyActions.setChapters(chapters: {any})
	if DEBUG_MODE then
		print("[LobbyActions] setChapters: " .. tostring(#chapters) .. " capitulos")
	end
	RootStore.producer.lobby.setChapters(chapters)
end

return LobbyActions
