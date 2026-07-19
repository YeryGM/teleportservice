local DEBUG_MODE = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reflex = require(ReplicatedStorage.packages.Reflex)
local LobbyState = require(script.Parent.LobbyState)

local LobbyProducer = Reflex.createProducer(
	LobbyState.createInitialState(),
	{
		openLobby = function(state)
			local next = table.clone(state)
			next.isOpen = true
			if DEBUG_MODE then
				print("[LobbyProducer] openLobby -> isOpen = true")
			end
			return next
		end,

		closeLobby = function(state)
			local next = table.clone(state)
			next.isOpen = false
			if DEBUG_MODE then
				print("[LobbyProducer] closeLobby -> isOpen = false")
			end
			return next
		end,

		setDifficulty = function(state, difficulty: number)
			local next = table.clone(state)
			next.difficulty = difficulty
			if DEBUG_MODE then
				print("[LobbyProducer] setDifficulty: " .. tostring(difficulty))
			end
			return next
		end,

		setChapter = function(state, chapter: string)
			local next = table.clone(state)
			next.chapterSelected = chapter
			if DEBUG_MODE then
				print("[LobbyProducer] setChapter: " .. chapter)
			end
			return next
		end,

		setChapters = function(state, chapters: {any})
			local next = table.clone(state)
			next.chapters = chapters
			if DEBUG_MODE then
				print("[LobbyProducer] setChapters: " .. tostring(#chapters) .. " capitulos")
			end
			return next
		end,

		reset = function()
			if DEBUG_MODE then
				print("[LobbyProducer] reset")
			end
			return LobbyState.createInitialState()
		end,
	}
)

return LobbyProducer
