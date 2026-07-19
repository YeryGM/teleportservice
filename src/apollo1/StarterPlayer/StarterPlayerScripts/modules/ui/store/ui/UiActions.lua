local RootStore = require(script.Parent.Parent.RootStore)
local UiEnums = require(script.Parent.UiEnums)

local UiActions = {}

function UiActions.setMode(mode:number)
    RootStore.producer.ui.setMode(mode)
end

function UiActions.setGameplay()
    UiActions.setMode(UiEnums.UiMode.Gameplay) 
end

function UiActions.setCutscene()
    UiActions.setMode(UiEnums.UiMode.Cutscene)
end

function UiActions.setMinigame()
    UiActions.setMode(UiEnums.UiMode.Minigame)
end

function UiActions.setCrafting()
    UiActions.setMode(UiEnums.UiMode.Crafting)
   
end

function UiActions.setShop()
    UiActions.setMode(UiEnums.UiMode.Shop)
end

function UiActions.setSpectator()
    UiActions.setMode(UiEnums.UiMode.Spectator)
end

function UiActions.setDead()
    UiActions.setMode(UiEnums.UiMode.Dead)
end

return UiActions