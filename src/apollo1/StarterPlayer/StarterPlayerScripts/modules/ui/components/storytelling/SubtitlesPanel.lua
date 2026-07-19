local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))
local useSubtitles = require(script.Parent.Parent.Parent.hooks.useSubtitles)

local SubtitleSection = require(script.Parent.subs.SubtitleSection)

local function SubtitlesPanel()
    local visible = useSubtitles.useVisible()
    if not visible then
        return nil
    end
    local sections = useSubtitles.useSubtitles()
    local subtitleSections = {}
    for sectionId, _ in pairs(sections) do
        local section = React.createElement(SubtitleSection, {
            sectionId = sectionId,
        })
        table.insert(subtitleSections, section)
    end

    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.7, 0.08),
        Position = UDim2.fromScale(0.5, 0.9),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, subtitleSections)
end

return SubtitlesPanel
