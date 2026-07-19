local CountDown = {
    debugOn = false,
    countdowns = {},
}
CountDown.__index = CountDown

local function startCountdown(remote:RemoteEvent, duration: number, targetPlayers:{Player}?)
    if not remote or not remote:IsA("RemoteEvent") then
        warn("CountDown: Invalid RemoteEvent provided")
        return
    end
    if not duration or duration <= 0 then
        if CountDown.debugOn then
            warn("CountDown: Invalid duration for countdown:", duration)
        end
        return
    end
    local startTime = workspace:GetServerTimeNow()
    local endTime = startTime + duration
    
    if targetPlayers then
        for _, player in ipairs(targetPlayers) do
            if not player:IsA("Player") then
                if CountDown.debugOn then
                    warn("CountDown: Invalid player in targetPlayers list")
                end
                return
            end
            remote:FireClient(player, {
            startTime = startTime,
            endTime = endTime,
            duration = duration})
        end
    else
        remote:FireAllClients({
        startTime = startTime,
        endTime = endTime,
        duration = duration})
    end
    return {
        startTime = startTime,
        endTime = endTime,
        duration = duration,
    }
end

function CountDown.new(remote:RemoteEvent, duration: number, onFinished, targetPlayers:{Player}?)
    local self = setmetatable({}, CountDown)
    self.remote = remote
    self.duration = duration
    self.onFinished = onFinished
    self.targetPlayers = targetPlayers
    self.id = nil
    self.countdownData = nil
    self.finished = false
    self.thread = nil
    self:load()
    CountDown.countdowns[self.id] = self
    return self
end

function CountDown:load()
    self.countdownData = startCountdown(self.remote, self.duration, self.targetPlayers)
    self.id = tostring(self.countdownData.startTime) .. "_" .. tostring(self.countdownData.endTime)
    self.thread = task.delay(self.duration, function()
        if self.finished then return end
        self.finished = true
        if self.onFinished then
            self.onFinished()
        end
        self:unload()
    end)
end

function CountDown:unload()
    if self.thread then
        task.cancel(self.thread)
        self.thread = nil
    end
    CountDown.countdowns[self.id] = nil
end

return CountDown