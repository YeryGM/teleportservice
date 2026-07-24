local debugOn = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local Enums = require(ReplicatedStorage.modules.general.data.Enums)
local useLobby = require(script.Parent.Parent.Parent.hooks.useLobby)
local LobbyActions = require(script.Parent.Parent.Parent.store.lobby.LobbyActions)
local UISLobby = require(script.Parent.Parent.Parent.services.UISLobby)
local Button = require(script.Parent.Parent.common.Button)
local OptionSelector = require(script.Parent.Parent.common.OptionSelector)

local DIFFICULTY_VALUES = {
	Enums.diff.Normal,
	Enums.diff.Nightmare,
}

local DIFFICULTY_LABELS = {
	[1] = "Normal",
	[2] = "Nightmare",
}

local function LobbyPanel()
	local isOpen = useLobby.useOpen()
	local chapters = useLobby.useChapters()
	local chapterIndex = useLobby.useChapterIndex()
	local difficultyIndex = useLobby.useDifficultyIndex()
	local partySize = useLobby.usePartySize()

	if not isOpen then
		return nil
	end

	local chapter = chapters[chapterIndex]
	local chapterName = chapter and chapter.displayName or "—"
	local diffLabel = DIFFICULTY_LABELS[difficultyIndex] or "?"

	local submitColor = chapter and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(35, 35, 35)

	local function onSubmit()
		if not chapter then
			return
		end
		local diffValue = DIFFICULTY_VALUES[difficultyIndex]
		if debugOn then
			print("[LobbyPanel] Submit -> chapter: " .. chapter.key
				.. ", difficulty: " .. tostring(diffValue)
				.. ", partySize: " .. tostring(partySize))
		end
		UISLobby.submitConfig(chapter.key, diffValue, partySize)
		LobbyActions.closeLobby()
	end

	local function onCancel()
		if debugOn then
			print("[LobbyPanel] Cancel")
		end
		UISLobby.cancel()
		LobbyActions.closeLobby()
	end

	return React.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Overlay = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}),
		Panel = React.createElement("Frame", {
			Size = UDim2.fromOffset(340, 350),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderSizePixel = 0,
		}, {
			UIPadding = React.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 16),
				PaddingBottom = UDim.new(0, 16),
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16),
			}),
			UICorner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 12),
			}),
			Title = React.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 32),
				LayoutOrder = 1,
				BackgroundTransparency = 1,
				Text = "Configurar Partida",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 20,
				Font = Enum.Font.GothamBold,
			}),
			ChapterSelector = React.createElement(OptionSelector, {
				label = "Capitulo:",
				value = chapterName,
				onPrev = LobbyActions.prevChapter,
				onNext = LobbyActions.nextChapter,
				layoutOrder = 2,
			}),
			DifficultySelector = React.createElement(OptionSelector, {
				label = "Dificultad:",
				value = diffLabel,
				onPrev = LobbyActions.prevDifficulty,
				onNext = LobbyActions.nextDifficulty,
				layoutOrder = 3,
			}),
			PartySelector = React.createElement(OptionSelector, {
				label = "Party:",
				value = tostring(partySize),
				onPrev = LobbyActions.decrementParty,
				onNext = LobbyActions.incrementParty,
				layoutOrder = 4,
			}),
			ActionsRow = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 40),
				LayoutOrder = 5,
				BackgroundTransparency = 1,
			}, {
				UIListLayout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 12),
				}),
				CancelButton = React.createElement(Button, {
					text = "Cancelar",
					size = UDim2.fromOffset(120, 40),
					layoutOrder = 1,
					backgroundColor = Color3.fromRGB(120, 40, 40),
					textSize = 14,
					onActivated = onCancel,
				}),
				SubmitButton = React.createElement(Button, {
					text = "Crear Partida",
					size = UDim2.fromOffset(140, 40),
					layoutOrder = 2,
					backgroundColor = submitColor,
					textSize = 14,
					onActivated = onSubmit,
				}),
			}),
		}),
	})
end

if debugOn then
	print("[LobbyPanel] Componente cargado")
end

return LobbyPanel
