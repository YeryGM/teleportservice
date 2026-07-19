local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))
local useSubtitles = require(script.Parent.Parent.Parent.Parent.hooks.useSubtitles)

local function SubtitlesSection(props)
    local sectionId = props.sectionId
    local visible = useSubtitles.useSectionVisible(sectionId)
    if not visible then
        return nil
    end
    local subtitle = useSubtitles.useSubtitle(sectionId)
    local speaker = subtitle.speaker or ""
    local text = subtitle.text or ""
    local labelText = ((speaker ~= "") and (speaker .. ": " .. text)) or text

    return React.createElement("Frame", {
        Size = UDim2.fromScale(0.7, 0.08),
        Position = UDim2.fromScale(0.5, 0.9),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, {
        Text = React.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = labelText,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Font = Enum.Font.GothamMedium,
            TextWrapped = true,
        }),
    })
end

return SubtitlesSection
