local debugOn = true

local RootStore = require(script.Parent.Parent.RootStore)

local LobbyActions = {}

function LobbyActions.getState()
	return RootStore.producer:getState().lobby
end

function LobbyActions.openLobby()
	if debugOn then
		print("[LobbyActions] openLobby")
	end
	RootStore.producer.lobby.openLobby()
end

function LobbyActions.closeLobby()
	if debugOn then
		print("[LobbyActions] closeLobby")
	end
	RootStore.producer.lobby.closeLobby()
end

function LobbyActions.setDifficulty(difficulty: number)
	if debugOn then
		print("[LobbyActions] setDifficulty: " .. tostring(difficulty))
	end
	RootStore.producer.lobby.setDifficulty(difficulty)
end

function LobbyActions.setChapter(chapter: string)
	if debugOn then
		print("[LobbyActions] setChapter: " .. chapter)
	end
	RootStore.producer.lobby.setChapter(chapter)
end

function LobbyActions.setChapters(chapters: {any})
	if debugOn then
		print("[LobbyActions] setChapters: " .. tostring(#chapters) .. " capitulos")
	end
	RootStore.producer.lobby.setChapters(chapters)
end

return LobbyActions
