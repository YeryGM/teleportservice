local CutsceneM = require(script.Parent.CutsceneM)
local Objective = require(script.Parent.Objective)

local StoryManager = {}

function StoryManager:load()
    CutsceneM:load()
    Objective.load()
end
function StoryManager:unload()
    CutsceneM:unload()
end

return StoryManager