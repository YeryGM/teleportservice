local ReplicatedStorage = game:GetService("ReplicatedStorage")
local dataFolder = ReplicatedStorage.modules.general.data
local Objectives = require(dataFolder.info.IFObjectives)
local Enums = require(dataFolder.Enums)

local UISObjectives = require(script.Parent.Parent.Parent.ui.services.UISObjectives)

local storyRemoteEvents = ReplicatedStorage.events.general.storytelling
local handleObjective: RemoteEvent = storyRemoteEvents.handleObjective

local timeout = 2 --time in seconds before completed objectives are removed

local ObjectiveC = {
    debugOn = false,
    conns = {},
}

local function getObjective(objectiveId: number)
    local objective = Objectives[objectiveId]
    if not objective then
        if ObjectiveC.debugOn then
            warn("Objective with id " .. objectiveId .. " does not exist")
        end
        return nil
    end
    return objective
end

function ObjectiveC:load()
    local conn = handleObjective.OnClientEvent:Connect(function(action: number, data)
        self:objectiveAction(data, action)
    end)
    table.insert(self.conns, conn)  
end

function ObjectiveC:unload()
    for _, conn in pairs(self.conns) do
        if conn and conn.Connected then
             conn:Disconnect()
        end
    end
    self.conns = {}
end

function ObjectiveC:objectiveAction(data, action)
    local objectiveId = data.id
    local objective = getObjective(objectiveId)
    if not objective then
        if self.debugOn then
            warn("Objective with id " .. objectiveId .. " does not exist")
        end
        return
    end
    data.text = objective.text
    local map = {
        [Enums.story.objectives.actions.show] = function() ObjectiveC:showObjective(data) end,
        [Enums.story.objectives.actions.subShow] = function() ObjectiveC:subShowObjective(data) end,
        [Enums.story.objectives.actions.complete] = function() ObjectiveC:completeObjective(data) end,
        [Enums.story.objectives.actions.subComplete] = function() ObjectiveC:subCompleteObjective(data) end,
    }
    local handler = map[action]
    if handler then
        handler()
    else
        if self.debugOn then
            warn("Invalid action " .. action .. " for objective " .. objectiveId)
        end
    end
end

function ObjectiveC:showObjective(data)
    if not assert((data.id and type(data.id) == "number"), "Invalid objective id") then return end
    local objective = getObjective(data.id)
    if not objective then
        return
    end
    local children = data.children or {}
    local showChildren = data.showChildren or false
    local subObjectives = {}
    if showChildren and children then
        for _, childId in pairs(data.children) do
            local childObjective = Objectives[childId]
            if childObjective then
                subObjectives[childId] = childObjective.text
            else
                if ObjectiveC.debugOn then
                    warn("Child objective with id " .. childId .. " does not exist for parent objective " .. data.id)
                end
            end
        end
    end
    UISObjectives:addObjective(data.id, objective.text, subObjectives)
end

function ObjectiveC:subShowObjective(data)
    if not assert((data.id and type(data.id) == "number"), "Invalid objective id") then return end
    local objective = getObjective(data.id)
    if not objective then
        return
    end
    local children = data.children or {}
    for _, childId in pairs(children) do
        local childObjective = Objectives[childId]
        if childObjective then
            UISObjectives:addSubObjective(data.id, childId, childObjective.text)
        else
            if self.debugOn then
                warn("Child objective with id " .. childId .. " does not exist for parent objective " .. data.id)
            end
        end
    end
end

function ObjectiveC:completeObjective(data)
    if not assert((data.id and type(data.id) == "number"), "Invalid objective id") then return end
    local objective = getObjective(data.id)
    if not objective then
        return
    end
    UISObjectives:completeObjective(data.id)
    task.delay(timeout, function()
        UISObjectives:removeObjective(data.id)
    end)
end

function ObjectiveC:subCompleteObjective(data)
    if not assert((data.id and type(data.id) == "number"), "Invalid objective id") then return end
    local objective = getObjective(data.id)
    if not objective then
        return
    end
    local children = data.children or {}
    for _, childId in pairs(children) do
        local childObjective = Objectives[childId]
        if childObjective then
            UISObjectives:completeSubObjective(data.id, childId)
        else
            if self.debugOn then
                warn("Child objective with id " .. childId .. " does not exist for parent objective " .. data.id)
            end
        end
    end
end



return ObjectiveC