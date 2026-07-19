local Cutscene = {
    --[[ isGlobal = false,
    isSkippable = false,
   ]]
}
Cutscene.__index = Cutscene

function Cutscene.new(players: {Player}, onEnd: () -> (), isGlobal: boolean, isSkippable: boolean)
    local self = setmetatable({}, Cutscene)
    self.players = players
    self.onEnd = onEnd
    self.isGlobal = isGlobal or false
    self.isSkippable = isSkippable or false
    self.timeline = {}
    self.threads = {}
    return self
end

function Cutscene:addAction(time:number, action: () -> ())
    table.insert(self.timeline, {time = time, action = action, processed = false})
end

function Cutscene:play()
    for _, entry in ipairs(self.timeline) do
        local waitTime = entry.time or 0
        if waitTime <= 0 then
            continue
        end
        local thread = task.delay(waitTime, function()
            if entry.action then
                entry.action(self)
            end
            entry.processed = true
        end)
        table.insert(self.threads, thread)
    end
end

function Cutscene:stop()
    for _, thread in ipairs(self.threads) do
        if coroutine.status(thread) ~= "dead" then
            task.cancel(thread)
        end
    end
    for _, entry in ipairs(self.timeline) do
        if not entry.processed and entry.action then
            entry.action(self)
        end
        entry.processed = true
    end
    self.threads = {}
    if self.onEnd then
        self.onEnd()
    end
end

return Cutscene