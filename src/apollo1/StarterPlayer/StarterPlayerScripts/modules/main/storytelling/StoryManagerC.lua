local CutsceneMC = require(script.Parent.CutsceneMC)
local DialoguesC = require(script.Parent.DialoguesC)
local ObjectiveC = require(script.Parent.ObjectiveC)

local StoryManagerC = {}

function StoryManagerC:load()
    CutsceneMC:load()
    DialoguesC:load()
    ObjectiveC:load()
end

function StoryManagerC:unload()
    CutsceneMC:unload()
    DialoguesC:unload()
    ObjectiveC:unload()
end

return StoryManagerC