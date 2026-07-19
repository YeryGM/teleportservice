local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IFCCutscenes = require(script.Parent.Parent.Parent.general.data.info.IFCCutscenes)
local UISCutscene = require(script.Parent.Parent.Parent.ui.services.UISCutscene)

local storyRemoteEvents = ReplicatedStorage.events.general.storytelling
local start: RemoteEvent = storyRemoteEvents.cutsceneStart
local stop: RemoteEvent = storyRemoteEvents.cutsceneStop
local skip: RemoteEvent = storyRemoteEvents.cutsceneSkip

type startPayload = {
    runId: number,
    cutsceneId: string,
    serverTime: number
}

type skipPayload = {
    runId: number,
    cutsceneId: string,
    votes: number,
    totalPlayers: number,
}

local CutsceneMC = {
    debugOn = false,
    currentCutsceneRunId = nil,
    currentCutscene = nil,
    conns = {},
}

function CutsceneMC:load()
    local conn = start.OnClientEvent:Connect(function(payload:startPayload)
        self:play(payload)
    end)
    table.insert(self.conns, conn)
    local conn2 = stop.OnClientEvent:Connect(function()
        self:stop()
    end)
    table.insert(self.conns, conn2)
    local conn3 = skip.OnClientEvent:Connect(function(payload:skipPayload)
        self:skip(payload)
    end)
    table.insert(self.conns, conn3)
end

function CutsceneMC:unload()
    for _, conn in pairs(self.conns) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    self.conns = {}
end

function CutsceneMC:play(payload:startPayload)
    if not payload or not payload.runId then
        if self.debugOn then
            warn("Invalid cutscene payload received on client: " .. tostring(payload))
        end
        return
    end
    local cutscene = IFCCutscenes[payload.cutsceneId]
    if not cutscene then
        if self.debugOn then
            warn("Cutscene id not found on client: " .. tostring(payload.cutsceneId))
        end
        return
    end
    if self.currentCutsceneRunId then
        self:stop()
    end
    local success, cutsceneInstance = pcall(function()
        return cutscene.new(payload.serverTime)
    end)
    if not success then
        if self.debugOn then
            warn("Failed to create cutscene instance: " .. tostring(cutsceneInstance))
        end
        return
    end
    self.currentCutscene = cutsceneInstance
    self.currentCutsceneRunId = payload.runId
    local bars = cutscene.bars
    UISCutscene.initCutscene(bars.on, bars.heightScale)
end

function CutsceneMC:stop()
    UISCutscene.endCutscene()
    if not self.currentCutscene then
        return
    end
    local success, err = pcall(function()
        return self.currentCutscene:stop()
    end)
    if not success then
        if self.debugOn then
            warn("Failed to stop cutscene instance: " .. tostring(err))
        end
    end
    self.currentCutscene = nil
    self.currentCutsceneRunId = nil
end

function CutsceneMC:skip(payload:skipPayload)
    if not payload or not payload.runId then
        if self.debugOn then
            warn("Invalid cutscene skip payload received on client: " .. tostring(payload))
        end
        return
    end
    if self.currentCutsceneRunId ~= payload.runId then return end
    
end

return CutsceneMC
