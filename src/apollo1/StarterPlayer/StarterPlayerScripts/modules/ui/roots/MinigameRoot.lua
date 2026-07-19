local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))
local UiSelectors = require(script.Parent.Parent.store.ui.UiSelectors)
local useStoreSelector = require(script.Parent.Parent.hooks.useStoreSelector)
local MinigamePanel = require(script.Parent.Parent.components.minigame.MinigamePanel)

local function MinigameRoot(props)
    local visible = useStoreSelector(UiSelectors.selectMinigameVisible)

    React.useEffect(function()
        if props.container then
            props.container.Enabled = visible
        end
    end, { visible, props.container })

    if not visible then
        return nil
    end

    return React.createElement("Folder", {
    }, {
        Minigame = React.createElement(MinigamePanel),
    })
end

return MinigameRoot
