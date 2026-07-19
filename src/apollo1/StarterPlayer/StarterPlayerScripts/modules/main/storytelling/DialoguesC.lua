local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dialogues = require(ReplicatedStorage.modules.general.data.info.IFDialogues)

local Audio = require(script.Parent.Audio)
local Subtitles = require(script.Parent.Subtitles)

local storyRemoteEvents = ReplicatedStorage.events.general.storytelling
local dialogueEvent:RemoteEvent = storyRemoteEvents.dialogue
local dialogueCueEvent:RemoteEvent = storyRemoteEvents.dialogueCue

local delayBetweenFragments = 0.25
local cueTimeout = 2

local DialoguesC = {
    conns = {},
    lanes = {
        --[1] = {busy = false, queue = {}, cueTasks = {}, activeCues = {}, token = 0}
    },
    cues = {},
    pendingCueEvents = {},
}

function DialoguesC:getLane(lane:number)
    if not self.lanes[lane] then
        self.lanes[lane] = {
            busy = false,
            queue = {},
            cueTasks = {},
            activeCues = {},
            token = 0,
        }
    end
    return self.lanes[lane]
end

function DialoguesC:clearLaneState(lane:number)
    local laneState = self.lanes[lane]
    if not laneState then
        return
    end
    for _, taskHandle in pairs(laneState.cueTasks) do
        if taskHandle then
            task.cancel(taskHandle)
        end
    end
    laneState.cueTasks = {}
    for cueId in pairs(laneState.activeCues) do
        self.cues[cueId] = nil
        self.pendingCueEvents[cueId] = nil
    end
    laneState.activeCues = {}
end

function DialoguesC:load()
    local conn = dialogueEvent.OnClientEvent:Connect(function(dialogueId:number, options)
        self:onDialogue(dialogueId, options)
    end)
    table.insert(self.conns, conn)

    local cueConn = dialogueCueEvent.OnClientEvent:Connect(function(dialogueId:number, cueId:number)
        self:onDialogueCueEvent(dialogueId*1000 + cueId)
    end)
    table.insert(self.conns, cueConn)
end

function DialoguesC:onDialogue(dialogueId:number, options)
    local dialogue = Dialogues[dialogueId]
    if not (dialogue and dialogue.lane) then
        return
    end
    local lane = self:getLane(dialogue.lane)
    if not lane.busy then
        lane.busy = true
        self:playDialogue(dialogueId, dialogue.lane, dialogue, options)
    else
        table.insert(lane.queue, {dialogueId, options})
    end
end

function DialoguesC:playNextDialogue(lane:number)
    local laneState = self.lanes[lane]
    if not laneState then
        return
    end
    self:clearLaneState(lane)
    if #laneState.queue > 0 then
        local nextDialogue = table.remove(laneState.queue, 1)
        self:playDialogue(nextDialogue[1], lane, Dialogues[nextDialogue[1]], nextDialogue[2])
    else
        laneState.busy = false
    end
end

function DialoguesC:playDialogue(dialogueId:number, lane:number, dialogue, options)
    if not dialogue or not dialogue.cues then
        self:playNextDialogue(lane)
        return
    end
    local laneState = self:getLane(lane)
    laneState.token += 1
    local token = laneState.token
    local dialogueStart = os.clock()
    local remainingCues = 0

    for id, cue in ipairs(dialogue.cues) do
        remainingCues += 1
        local cueKey = dialogueId * 1000 + id
        local waitTime = math.max((cue.time or 0) - (os.clock() - dialogueStart), 0)

        laneState.cueTasks[cueKey] = task.delay(waitTime, function()
            if laneState.token ~= token then
                return
            end
            laneState.cueTasks[cueKey] = nil
            self:playCue(dialogueId, id, cue, options, lane, token, function()
                remainingCues -= 1
                if laneState.token == token and remainingCues == 0 then
                    self:playNextDialogue(lane)
                end
            end)
        end)
    end

    if remainingCues == 0 then
        self:playNextDialogue(lane)
    end
end

function DialoguesC:playCue(
    dialogueId:number,
    cueId:number,
    dialogueFragment, 
    dialogueOptions,
    lane:number,
    token:number,
    onComplete
)
    local laneState = self.lanes[lane]
    if not laneState or laneState.token ~= token then
        if onComplete then
            onComplete()
        end
        return
    end

    local speaker:string = (dialogueOptions and dialogueOptions.speaker) or dialogueFragment.speaker
    local text:string = dialogueFragment.text
    local section:number = (dialogueOptions and dialogueOptions.section) or dialogueFragment.section
    local soundData = dialogueFragment.sound
    local cueKey = dialogueId * 1000 + cueId

    if not soundData then
        if onComplete then
            onComplete()
        end
        return
    end

    local function play()
        if laneState.token ~= token then
            if onComplete then
                onComplete()
            end
            return
        end
        self.pendingCueEvents[cueKey] = nil
        local handle = Audio:playAudio(soundData, dialogueOptions)
        local duration = dialogueFragment.duration or (handle and handle.duration) or cueTimeout
        Subtitles:displaySubtitle(speaker, text, section, duration)

        laneState.cueTasks[cueKey] = task.delay(duration + delayBetweenFragments, function()
            if laneState.token ~= token then
                if onComplete then
                    onComplete()
                end
                return
            end

            laneState.cueTasks[cueKey] = nil
            self.cues[cueKey] = nil
            laneState.activeCues[cueKey] = nil

            if onComplete then
                onComplete()
            end
        end)
    end

    if dialogueFragment.event then
        laneState.activeCues[cueKey] = true
        self.cues[cueKey] = {
            play = play,
            lane = lane,
            token = token,
        }
        if self.pendingCueEvents[cueKey] then
            self.pendingCueEvents[cueKey] = nil
            local cueState = self.cues[cueKey]
            self.cues[cueKey] = nil
            if cueState then
                cueState.play()
            end
            return
        end

        laneState.cueTasks[cueKey] = task.delay(cueTimeout, function()
            if laneState.token ~= token then
                if onComplete then
                    onComplete()
                end
                return
            end
            laneState.cueTasks[cueKey] = nil
            local cueState = self.cues[cueKey]
            if cueState then
                self.cues[cueKey] = nil
                cueState.play()
            end
        end)
    else
        play()
    end
end

function DialoguesC:onDialogueCueEvent(cueId:number)
    local cueState = self.cues[cueId]
    if cueState then
        local laneState = self.lanes[cueState.lane]
        if laneState and laneState.token == cueState.token then
            laneState.cueTasks[cueId] = nil
            self.cues[cueId] = nil
            cueState.play()
        end
    else
        self.pendingCueEvents[cueId] = true
    end
end

function DialoguesC:unload()
    for _, conn in pairs(self.conns) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    self.conns = {}

    for lane in pairs(self.lanes) do
        self:clearLaneState(lane)
    end
    self.lanes = {}
    self.cues = {}
    self.pendingCueEvents = {}
end

return DialoguesC