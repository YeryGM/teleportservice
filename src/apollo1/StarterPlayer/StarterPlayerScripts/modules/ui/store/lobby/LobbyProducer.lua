local debugOn = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reflex = require(ReplicatedStorage.packages.Reflex)
local Enums = require(ReplicatedStorage.modules.general.data.Enums)
local LobbyState = require(script.Parent.LobbyState)

local PARTY_MIN = 1
local PARTY_MAX = 5
local DIFF_COUNT = Enums.diff.COUNT

local LobbyProducer = Reflex.createProducer(
	LobbyState.createInitialState(),
	{
		openLobby = function(state)
			local next = table.clone(state)
			next.isOpen = true
			if debugOn then
				print("[LobbyProducer] openLobby -> isOpen = true")
			end
			return next
		end,

		closeLobby = function(state)
			local next = table.clone(state)
			next.isOpen = false
			if debugOn then
				print("[LobbyProducer] closeLobby -> isOpen = false")
			end
			return next
		end,

		setChapters = function(state, chapters: {any})
			local next = table.clone(state)
			next.chapters = chapters
			next.chapterIndex = 1
			if debugOn then
				print("[LobbyProducer] setChapters: " .. tostring(#chapters) .. " capitulos, index reset to 1")
			end
			return next
		end,

		nextChapter = function(state)
			local next = table.clone(state)
			local count = #state.chapters
			if count > 0 then
				next.chapterIndex = (state.chapterIndex % count) + 1
			end
			if debugOn then
				print("[LobbyProducer] nextChapter -> chapterIndex = " .. tostring(next.chapterIndex))
			end
			return next
		end,

		prevChapter = function(state)
			local next = table.clone(state)
			local count = #state.chapters
			if count > 0 then
				next.chapterIndex = ((state.chapterIndex - 2) % count) + 1
			end
			if debugOn then
				print("[LobbyProducer] prevChapter -> chapterIndex = " .. tostring(next.chapterIndex))
			end
			return next
		end,

		nextDifficulty = function(state)
			local next = table.clone(state)
			next.difficultyIndex = (state.difficultyIndex % DIFF_COUNT) + 1
			if debugOn then
				print("[LobbyProducer] nextDifficulty -> difficultyIndex = " .. tostring(next.difficultyIndex))
			end
			return next
		end,

		prevDifficulty = function(state)
			local next = table.clone(state)
			next.difficultyIndex = ((state.difficultyIndex - 2) % DIFF_COUNT) + 1
			if debugOn then
				print("[LobbyProducer] prevDifficulty -> difficultyIndex = " .. tostring(next.difficultyIndex))
			end
			return next
		end,

		incrementParty = function(state)
			local next = table.clone(state)
			next.partySize = math.min(state.partySize + 1, PARTY_MAX)
			if debugOn then
				print("[LobbyProducer] incrementParty -> partySize = " .. tostring(next.partySize))
			end
			return next
		end,

		decrementParty = function(state)
			local next = table.clone(state)
			next.partySize = math.max(state.partySize - 1, PARTY_MIN)
			if debugOn then
				print("[LobbyProducer] decrementParty -> partySize = " .. tostring(next.partySize))
			end
			return next
		end,

		reset = function()
			if debugOn then
				print("[LobbyProducer] reset")
			end
			return LobbyState.createInitialState()
		end,
	}
)

return LobbyProducer
