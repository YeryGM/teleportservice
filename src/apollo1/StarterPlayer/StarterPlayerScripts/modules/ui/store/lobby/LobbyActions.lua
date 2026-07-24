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
	RootStore.producer.openLobby()
end

function LobbyActions.closeLobby()
	if debugOn then
		print("[LobbyActions] closeLobby")
	end
	RootStore.producer.closeLobby()
end

function LobbyActions.setChapters(chapters: {any})
	if debugOn then
		print("[LobbyActions] setChapters: " .. tostring(#chapters) .. " capitulos")
	end
	RootStore.producer.setChapters(chapters)
end

function LobbyActions.nextChapter()
	if debugOn then
		print("[LobbyActions] nextChapter")
	end
	RootStore.producer.nextChapter()
end

function LobbyActions.prevChapter()
	if debugOn then
		print("[LobbyActions] prevChapter")
	end
	RootStore.producer.prevChapter()
end

function LobbyActions.nextDifficulty()
	if debugOn then
		print("[LobbyActions] nextDifficulty")
	end
	RootStore.producer.nextDifficulty()
end

function LobbyActions.prevDifficulty()
	if debugOn then
		print("[LobbyActions] prevDifficulty")
	end
	RootStore.producer.prevDifficulty()
end

function LobbyActions.incrementParty()
	if debugOn then
		print("[LobbyActions] incrementParty")
	end
	RootStore.producer.incrementParty()
end

function LobbyActions.decrementParty()
	if debugOn then
		print("[LobbyActions] decrementParty")
	end
	RootStore.producer.decrementParty()
end

return LobbyActions
