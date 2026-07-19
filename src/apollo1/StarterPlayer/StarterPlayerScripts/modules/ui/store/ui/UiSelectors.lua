local UiEnums = require(script.Parent.UiEnums)

local UiSelectors = {}

function UiSelectors.getVisibility(state)
    local mode = state.mode
    local visibility = UiEnums.Components[mode] or {}
    return visibility
end

function UiSelectors.selectUiMode(state)
    return state.mode
end

function UiSelectors.selectDeathScreenState(state)
    local visibility = UiSelectors.getVisibility(state)
    return visibility[UiEnums.uiComponents.death]
end

function UiSelectors.selectModalVisible(state)
    local visibility = UiSelectors.getVisibility(state)
    return visibility[UiEnums.uiComponents.death] or visibility[UiEnums.uiComponents.shop] or visibility[UiEnums.uiComponents.crafting]
end

function UiSelectors.selectGameplayVisible(state)
    local visibility = UiSelectors.getVisibility(state)
    return visibility[UiEnums.uiComponents.hud] or visibility[UiEnums.uiComponents.stamina] or visibility[UiEnums.uiComponents.qte]
end

function UiSelectors.selectOverlayVisible(state)
    local visibility = UiSelectors.getVisibility(state)
    return visibility[UiEnums.uiComponents.subtitles] or visibility[UiEnums.uiComponents.objectives] or visibility[UiEnums.uiComponents.cutscene]
end

function UiSelectors.selectMinigameVisible(state)
    local visibility = UiSelectors.getVisibility(state)
    return visibility[UiEnums.uiComponents.minigame]
end

function UiSelectors.selectHudVisible(state)
    return UiSelectors.getVisibility(state)[UiEnums.uiComponents.hud]
end

function UiSelectors.selectObjectivesVisible(state)
    return UiSelectors.getVisibility(state)[UiEnums.uiComponents.objectives]
end

function UiSelectors.selectStaminaVisible(state)
    return UiSelectors.getVisibility(state)[UiEnums.uiComponents.stamina]
end

function UiSelectors.selectQteVisible(state)
    return UiSelectors.getVisibility(state)[UiEnums.uiComponents.qte]
end

function UiSelectors.selectSubtitlesVisible(state)
    return UiSelectors.getVisibility(state)[UiEnums.uiComponents.subtitles]
end

function UiSelectors.selectCutsceneVisible(state)
    return UiSelectors.getVisibility(state)[UiEnums.uiComponents.cutscene]
end

function UiSelectors.selectShopVisible(state)
    return UiSelectors.getVisibility(state)[UiEnums.uiComponents.shop]
end

function UiSelectors.selectCraftingVisible(state)
    return UiSelectors.getVisibility(state)[UiEnums.uiComponents.crafting]
end

return UiSelectors
