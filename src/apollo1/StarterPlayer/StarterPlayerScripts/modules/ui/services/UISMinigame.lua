local UIActions = require(script.Parent.Parent.store.ui.UiActions)
--local MinigameActions = require(script.Parent.Parent.store.minigame.MinigameActions)

local UISMinigame = {}

function UISMinigame.startMinigame()
    UIActions.setMinigame()
end

return UISMinigame
