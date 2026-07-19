local Objective = require(script.Parent.Objective)
local Dialogue = require(script.Parent.Dialogue)
local CutsceneM = require(script.Parent.CutsceneM)

local StoryTeller = {
    debugOn = false,
}
StoryTeller.__index = StoryTeller

function StoryTeller.new()
    local self = setmetatable({}, StoryTeller)
    self.threads = {}
    self.actions = {}
    self.current = 0
    self.total = 0
    self.ended = false
    return self
end

function StoryTeller:load()
    --VERIFY IF ENDED IN CHILDREN
    --HERE THE ACTIONS ARE LOADED in each children
    --and after that the play function is called 
    self:play()
end

function StoryTeller:unload()
    for _, thread in ipairs(self.threads) do
        if thread and coroutine.status(thread) ~= "dead" then
            task.cancel(thread)
        end
    end
    table.clear(self.threads)
end

function StoryTeller:register()
    self.total += 1
end

function StoryTeller:check()
    if self.current >= self.total then
        self.ended = true
        if self.debugOn then
            warn("All actions executed in StoryTeller:check")
        end 
    end
end

function StoryTeller:addAction(action, timeOffset:number)
    if not action or type(action) ~= "function" then
        if self.debugOn then
            warn("Invalid action provided to StoryTeller:addAction")
        end
        return
    end
    if not timeOffset or type(timeOffset) ~= "number" or timeOffset <= 0 then
        if self.debugOn then
            warn("Invalid timeOffset provided to StoryTeller:addAction")
        end
        return
    end
    self:register()
    table.insert(self.actions, {action = action, timeOffset = timeOffset, executed = false})
end

function StoryTeller:executeAction(actionData)
    if not actionData.action or type(actionData.action) ~= "function" then
        if self.debugOn then
            warn("Invalid action in actionData provided to StoryTeller:executeAction")
        end
        return
    end
    local success, err = pcall(actionData.action)
    if not success then
        warn("Failed to execute action in StoryTeller:executeAction: ", tostring(err))
        return
    end
    actionData.executed = true
    self.current += 1
    self:check()
end

function StoryTeller:play()
    if self.current >= #self.actions then
        if self.debugOn then
            warn("No actions to play in StoryTeller:play")
        end
        return
    end
    for _, actionData in ipairs(self.actions) do
        if not actionData.executed then
            local thread = task.delay(actionData.timeOffset, function()
                self:executeAction(actionData)
            end)
            table.insert(self.threads, thread)
        end
    end
end

function StoryTeller:playCutsceneMultiple(cutsceneId: number, players: {Player}?, onEnd:()->()?, timeOffset: number?)
    if not cutsceneId or type(cutsceneId) ~= "number" then
        if self.debugOn then
            warn("Invalid cutsceneId provided to StoryTeller:playCutsceneMultiple")
        end
        return
    end
    self:addAction(function()
        CutsceneM:playMultiple(cutsceneId, players, onEnd)
    end, timeOffset)
end

function StoryTeller:playCutsceneSingle(cutsceneId: number, player: Player, onEnd:()->()?, timeOffset: number?)
    if not cutsceneId or type(cutsceneId) ~= "number" then
        if self.debugOn then
            warn("Invalid cutsceneId provided to StoryTeller:playCutsceneSingle")
        end
        return
    end
    self:addAction(function()
        CutsceneM:playSingle(cutsceneId, player, onEnd)
    end, timeOffset)
end

function StoryTeller:showObjective(objectiveId: number, showChildren: boolean, timeOffset: number?)
    if not objectiveId or type(objectiveId) ~= "number" then
        if self.debugOn then
            warn("Invalid objectiveId provided to StoryTeller:showObjective")
        end
        return
    end
    self:addAction(function()
       Objective.showById(objectiveId, showChildren)
    end, timeOffset)
end

function StoryTeller:completeObjective(objectiveId: number, timeOffset: number?)
    if not objectiveId or type(objectiveId) ~= "number" then
        if self.debugOn then
            warn("Invalid objectiveId provided to StoryTeller:completeObjective")
        end
        return
    end
    self:addAction(function()
       Objective.completeById(objectiveId)
    end, timeOffset)
end

function StoryTeller:showSubObjective(objectiveId: number, all: boolean, subObjectiveId: number, timeOffset: number?)
    if not objectiveId or type(objectiveId) ~= "number" then
        if self.debugOn then
            warn("Invalid objectiveId provided to StoryTeller:showSubObjective")
        end
        return
    end
    self:addAction(function()
       Objective.subShowById(objectiveId, all, subObjectiveId)
    end, timeOffset)
end

function StoryTeller:completeSubObjective(objectiveId: number, subObjectiveId: number, timeOffset: number?)
    if not objectiveId or type(objectiveId) ~= "number" then
        if self.debugOn then
            warn("Invalid objectiveId provided to StoryTeller:completeSubObjective")
        end
        return
    end
    self:addAction(function()
       Objective.subCompleteById(objectiveId, subObjectiveId)
    end, timeOffset)
end

function StoryTeller:playDialogue(dialogueId: number, player: Player?, timeOffset: number?)
    if not dialogueId or type(dialogueId) ~= "number" then
        if self.debugOn then
            warn("Invalid dialogueId provided to StoryTeller:playDialogue")
        end
        return
    end
    self:addAction(function()
       Dialogue.play(dialogueId, player)
    end, timeOffset)
end

return StoryTeller