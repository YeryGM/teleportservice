local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Reflex = require(packages:WaitForChild("Reflex"))

local UiEnums = require(script.Parent.UiEnums)
local UiState = require(script.Parent.UiState) 

local function withMode(state, nextMode: number)
    local currentMode = state.mode
    if currentMode == nextMode then
        return state
    end

    local canTransition = UiEnums.Transitions[currentMode] and UiEnums.Transitions[currentMode][nextMode]
    if not canTransition then
        return state
    end
    local newState = table.clone(state)
    for component, _ in pairs(UiEnums.Components[currentMode]) do
        newState.components[component] = false
    end
    for component, _ in pairs(UiEnums.Components[nextMode]) do
        newState.components[component] = true
    end
    newState.mode = nextMode
    return newState
end

local UiProducer = Reflex.createProducer(
    UiState.createInitialState(), 
    {
    setMode = function(state, mode:number)
        return withMode(state, mode)
    end,
})

return UiProducer