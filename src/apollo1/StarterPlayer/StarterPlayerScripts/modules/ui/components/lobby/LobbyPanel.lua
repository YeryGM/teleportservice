local DEBUG_MODE = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local Enums = require(ReplicatedStorage.modules.general.data.Enums)
local useLobby = require(script.Parent.Parent.Parent.hooks.useLobby)
local LobbyActions = require(script.Parent.Parent.Parent.store.lobby.LobbyActions)
local UISLobby = require(script.Parent.Parent.Parent.services.UISLobby)
local Button = require(script.Parent.Parent.common.Button)

local DIFFICULTY_KEYS = {
	[Enums.lobby.difficulty.Easy] = "Easy",
	[Enums.lobby.difficulty.Normal] = "Normal",
	[Enums.lobby.difficulty.Hard] = "Hard",
}

local DIFFICULTY_VALUES = {
	Enums.lobby.difficulty.Easy,
	Enums.lobby.difficulty.Normal,
	Enums.lobby.difficulty.Hard,
}

local function LobbyPanel()
	local isOpen = useLobby.useOpen()
	local chapters = useLobby.useChapters()
	local chapterSelected = useLobby.useChapterSelected()
	local difficulty = useLobby.useDifficulty()

	if not isOpen then
		return nil
	end

	local hasChapter = chapterSelected ~= nil and chapterSelected ~= ""

	local function onSetChapter(chapterKey)
		LobbyActions.setChapter(chapterKey)
	end

	local function onSetDifficulty(diff)
		LobbyActions.setDifficulty(diff)
	end

	local function onSubmit()
		if not hasChapter then
			return
		end
		if DEBUG_MODE then
			print("[LobbyPanel] Submit -> chapter: " .. chapterSelected
				.. ", difficulty: " .. tostring(difficulty))
		end
		UISLobby.submitConfig(chapterSelected, difficulty)
		LobbyActions.closeLobby()
	end

	local function onCancel()
		if DEBUG_MODE then
			print("[LobbyPanel] Cancel")
		end
		UISLobby.cancel()
		LobbyActions.closeLobby()
	end

	local chapterButtons = {}
	for i, chapter in ipairs(chapters) do
		local isActive = chapterSelected == chapter.key
		chapterButtons["Chapter_" .. chapter.key] = React.createElement(Button, {
			text = chapter.displayName,
			size = UDim2.fromOffset(90, 36),
			layoutOrder = i,
			backgroundColor = isActive and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(50, 50, 50),
			textSize = 14,
			onActivated = function()
				onSetChapter(chapter.key)
			end,
		})
	end

	local difficultyButtons = {}
	for i, diffValue in ipairs(DIFFICULTY_VALUES) do
		local label = DIFFICULTY_KEYS[diffValue]
		local isActive = difficulty == diffValue
		difficultyButtons["Diff_" .. label] = React.createElement(Button, {
			text = label,
			size = UDim2.fromOffset(90, 36),
			layoutOrder = i,
			backgroundColor = isActive and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(50, 50, 50),
			textSize = 14,
			onActivated = function()
				onSetDifficulty(diffValue)
			end,
		})
	end

	local submitColor = hasChapter and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(35, 35, 35)

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
			Size = UDim2.fromOffset(340, 300),
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
			ChapterRow = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				LayoutOrder = 2,
				BackgroundTransparency = 1,
			}, {
				UIListLayout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 8),
				}),
				ChapterLabel = React.createElement("TextLabel", {
					Size = UDim2.fromOffset(80, 36),
					LayoutOrder = 1,
					BackgroundTransparency = 1,
					Text = "Capitulo:",
					TextColor3 = Color3.fromRGB(180, 180, 180),
					TextSize = 14,
					Font = Enum.Font.GothamMedium,
				}),
				ChapterButtons = React.createElement("Frame", {
					Size = UDim2.fromOffset(280, 36),
					LayoutOrder = 2,
					BackgroundTransparency = 1,
				}, {
					UIListLayout = React.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 8),
					}),
				}, chapterButtons),
			}),
			DifficultyRow = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				LayoutOrder = 3,
				BackgroundTransparency = 1,
			}, {
				UIListLayout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 8),
				}),
				DifficultyLabel = React.createElement("TextLabel", {
					Size = UDim2.fromOffset(80, 36),
					LayoutOrder = 1,
					BackgroundTransparency = 1,
					Text = "Dificultad:",
					TextColor3 = Color3.fromRGB(180, 180, 180),
					TextSize = 14,
					Font = Enum.Font.GothamMedium,
				}),
				DifficultyButtons = React.createElement("Frame", {
					Size = UDim2.fromOffset(280, 36),
					LayoutOrder = 2,
					BackgroundTransparency = 1,
				}, {
					UIListLayout = React.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 8),
					}),
				}, difficultyButtons),
			}),
			ActionsRow = React.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 40),
				LayoutOrder = 4,
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

if DEBUG_MODE then
	print("[LobbyPanel] Componente cargado")
end

return LobbyPanel
