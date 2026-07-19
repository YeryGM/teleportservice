
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useCutscene = require(script.Parent.Parent.Parent.Parent.hooks.useCutscene)

local function CutsceneSkip()
    local visible = useCutscene.selectSkipVisible() 
    if not visible then
        return nil
    end
    local skipVotes = useCutscene.selectSkipVotes()
    local voted:number = skipVotes.voted
    local totalVotes:number = skipVotes.totalVotes

    return React.createElement("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    }, {
        SkipVotes = React.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = voted .. "/" .. totalVotes,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true,
        })
    })
end

return CutsceneSkip
