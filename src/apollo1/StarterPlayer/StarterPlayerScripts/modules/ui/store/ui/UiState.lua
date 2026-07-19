local UiEnums = require(script.Parent.UiEnums)

local UiState = {}
function UiState.createInitialState()
    local components = {}
    for _componentName, id in pairs(UiEnums.uiComponents) do
        components[id] = false
    end
    return {
        mode = UiEnums.UiMode.None,
        components = components
    }
end

return UiState
