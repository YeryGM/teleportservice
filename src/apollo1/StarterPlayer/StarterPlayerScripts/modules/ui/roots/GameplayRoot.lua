local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))
local UiSelectors = require(script.Parent.Parent.store.ui.UiSelectors)
local useStoreSelector = require(script.Parent.Parent.hooks.useStoreSelector)
local MainHud = require(script.Parent.Parent.components.hud.MainHud)
local StaminaBar = require(script.Parent.Parent.components.hud.StaminaBar)
local QtePanel = require(script.Parent.Parent.components.hud.QtePanel)

local function GameplayRoot(props)
    local visible = useStoreSelector(UiSelectors.selectGameplayVisible)

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
        MainHud = React.createElement(MainHud),
        Stamina = React.createElement(StaminaBar),
        Qte = React.createElement(QtePanel),
    })
end

return GameplayRoot
