local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useCutscene = require(script.Parent.Parent.Parent.hooks.useCutscene)
local cutsceneFolder = script.Parent.cutscenes
local Bars = require(cutsceneFolder.CutsceneBars)
local InitSkip = require(cutsceneFolder.InitSkip)
local SkipVotes = require(cutsceneFolder.CutsceneSkip)

local function CutscenePanel()
    local visible = useCutscene.selectVisible()
    if not visible then
        return nil
    end

    return React.createElement("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    }, {
        Bars = React.createElement(Bars),
        InitSkip = React.createElement(InitSkip),
        SkipVotes = React.createElement(SkipVotes),
    })
end

return CutscenePanel
