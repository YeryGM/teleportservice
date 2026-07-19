local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))
local UiSelectors = require(script.Parent.Parent.store.ui.UiSelectors)
local useStoreSelector = require(script.Parent.Parent.hooks.useStoreSelector)
local SubtitlesPanel = require(script.Parent.Parent.components.storytelling.SubtitlesPanel)
local ObjectivesPanel = require(script.Parent.Parent.components.storytelling.ObjectivesPanel)
local CutscenePanel= require(script.Parent.Parent.components.storytelling.CutscenePanel)

local function OverlayRoot(props)
    local visible = useStoreSelector(UiSelectors.selectOverlayVisible)

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
        Subtitles = React.createElement(SubtitlesPanel),
        Objectives = React.createElement(ObjectivesPanel),
        Cutscene = React.createElement(CutscenePanel),
    })
end

return OverlayRoot
