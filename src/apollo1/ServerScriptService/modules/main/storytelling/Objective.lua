local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Objectives = require(ReplicatedStorage.modules.general.data.info.IFObjectives)
local Enums = require(ReplicatedStorage.modules.general.data.Enums)

local storyRemoteEvents = ReplicatedStorage.events.general.storytelling
local handleObjective: RemoteEvent = storyRemoteEvents.handleObjective

local Objective = {
    objectiveMap = {},
    debugOn = false,
}
Objective.__index = Objective

function Objective.load()
    for id, data in pairs(Objectives) do
        local objective = Objective.new(id, data.children, data.prev, data.next)
        Objective.objectiveMap[id] = objective
    end
end

function Objective.new(id:number, children:{number}, prev:{number}, next:number)
    local self = setmetatable({}, Objective)
    self.id = id
    self.status = Enums.story.objectives.states.incomplete
    self.children = children or {}
    self.prev = prev or {}
    self.next = next or nil
    return self
end

function Objective:verifyList(nodes:{number}, status:number)
    for _, nodeId in pairs(nodes) do
        local objective = Objective.objectiveMap[nodeId]
        if not objective or objective.status ~= status then
            return false
        end
    end
    return true
end

function Objective:show(showChildren:boolean)
    if self.status ~= Enums.story.objectives.states.incomplete then return end
    local ok = self:verifyList(self.prev, Enums.story.objectives.states.complete)
    if not ok then
        if Objective.debugOn then
            warn("Cannot show objective " .. self.id .. " because prev are not complete")
        end  
        return 
    end
    local data = {}
    data.id = self.id
    data.showChildren = showChildren
    if showChildren then
        data.children = self.children
    end
    handleObjective:FireAllClients(Enums.story.objectives.actions.show, data)
    self.status = Enums.story.objectives.states.inProgress
end

local function subChangeById(id:number, status:number)
    local objective = Objective.objectiveMap[id]
    if objective then
        objective.status = status
    end
end

function Objective:subShow(all:boolean, subObjectiveId:number)
    if self.status == Enums.story.objectives.states.complete then return end
    local data = nil
    if all then
        data = {id = self.id, children = self.children}
        for _, subId in pairs(self.children) do
            subChangeById(subId, Enums.story.objectives.states.inProgress)
        end
    else
        data = {id = self.id, children = {subObjectiveId}}
        subChangeById(subObjectiveId, Enums.story.objectives.states.inProgress)
    end
    handleObjective:FireAllClients(Enums.story.objectives.actions.subShow, data)  
end

function Objective:complete()
    if self.status ~= Enums.story.objectives.states.inProgress then return end
    local ok = self:verifyList(self.children, Enums.story.objectives.states.complete)
    if not ok then
        if Objective.debugOn then
            warn("Cannot complete objective " .. self.id .. " because not all children are complete")
        end 
        return 
    end
    handleObjective:FireAllClients(Enums.story.objectives.actions.complete, {id = self.id})
    self.status = Enums.story.objectives.states.complete
end

function Objective:subComplete(all:boolean, subObjectiveId:number)
    if self.status == Enums.story.objectives.states.complete then return end
    local data = nil
    if all then 
        for _, subId in pairs(self.children) do
            subChangeById(subId, Enums.story.objectives.states.complete)
        end
        data = {id = self.id, children = self.children}
    else
        subChangeById(subObjectiveId, Enums.story.objectives.states.complete)
        data = {id = self.id, children = {subObjectiveId}}
    end
    handleObjective:FireAllClients(Enums.story.objectives.actions.subComplete, data)
end

function Objective.completeById(id:number)
    local objective = Objective.objectiveMap[id]
    if objective then
        objective:complete()
    end
end

function Objective.subCompleteById(id:number, subObjectiveId:number)
    local objective = Objective.objectiveMap[id]
    if objective then
        objective:subComplete(false, subObjectiveId)
    end
end

function Objective.showById(id:number, showChildren:boolean)
    local objective = Objective.objectiveMap[id]
    if objective then
        objective:show(showChildren)
    end
end

function Objective.subShowById(id:number, all:boolean, subObjectiveId:number)
    local objective = Objective.objectiveMap[id]
    if objective then
        objective:subShow(all, subObjectiveId)
    end
end

return Objective