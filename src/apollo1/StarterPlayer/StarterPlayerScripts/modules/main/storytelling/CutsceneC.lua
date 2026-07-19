local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local DialoguesC = require(script.Parent.DialoguesC)
local Audio = require(script.Parent.Audio)
local Subtitles = require(script.Parent.Subtitles)

type keyframe = {
    cframe: CFrame,
    tweenInfo: TweenInfo?,
}

local CutsceneC = {
    timeline = {
        --[[ {time = 0, action = function(self) end} ]]
    },
}
CutsceneC.__index = CutsceneC

function CutsceneC.new(serverTime:number)
    local self = setmetatable({}, CutsceneC)
    self.serverTime = serverTime
    self.camera = Workspace.CurrentCamera
    self.tweens = {}
    self.sounds = {}
    self.threads = {}
    return self
end

function CutsceneC:play()
    local startTime = os.clock()
    local delayed = Workspace:GetServerTimeNow() - self.serverTime 
    for _, entry in ipairs(self.timeline) do 
        local waitTime = math.max(((entry.time or 0) - (os.clock() - startTime) - delayed), 0)
        local thread = task.delay(waitTime, function()
            if entry.action then
                entry.action(self)
            end
        end)
        table.insert(self.threads, thread)
    end
end

function CutsceneC:stop()
    for _, thread in ipairs(self.threads) do
        if coroutine.status(thread) ~= "dead" then
            task.cancel(thread)
        end
    end
    for _, tween in ipairs(self.tweens) do
        if tween and tween.PlaybackState == Enum.PlaybackState.Playing then
            tween:Cancel()
        end
    end
    table.clear(self.threads)
    table.clear(self.tweens)
end

function CutsceneC:addAction(time:number, action: () -> ())
    table.insert(self.timeline, {time = time, action = action})
end

function CutsceneC:addTween(time:number, tween:Tween)
    self:addAction(time, function()
        tween:Play()
    end)
    table.insert(self.tweens, tween)
end

function CutsceneC:addSound(time:number, soundConfig, options)
    self:addAction(time, function()
        Audio:playAudio(soundConfig, options)
    end)
end

function CutsceneC:addDialogue(time:number, dialogueId: number )
    self:addAction(time, function()
        DialoguesC:onDialogue(dialogueId)
    end)
end

function CutsceneC:addSubtitle(time:number, speaker:string?, text:string, section:number?, duration:number?)
    self:addAction(time, function()
        Subtitles:displaySubtitle(speaker, text, section, duration)
    end)
end

function CutsceneC:addCameraSequence(time:number, keyframes:{[number]: keyframe})
    self:addAction(time, function()
        self:runCameraSequence(keyframes)
    end)
end

function CutsceneC:runCameraSequence(keyframes:{[number]: keyframe})
    if type(keyframes) ~= "table" or #keyframes == 0 then
        return
    end
    self.camera.CameraType = Enum.CameraType.Scriptable
    for _, frame in ipairs(keyframes) do
        local duration = frame.tweenInfo.Time or 0
        if duration <= 0 then
            continue
        end
        local tween = TweenService:Create(self.camera, frame.tweenInfo, {CFrame = frame.cframe})
        table.insert(self.tweens, tween)
        tween:Play()
        tween.Completed:Wait()
    end
end

return CutsceneC