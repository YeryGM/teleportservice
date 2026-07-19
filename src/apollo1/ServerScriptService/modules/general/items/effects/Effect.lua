local Effect = {
    debugOn = false
}
Effect.__index = Effect

function Effect.new(player:Player, onRemove)
    local self = setmetatable({}, Effect)
    self.player = player
    self.duration = 0
    self.isReappliable = true
    self.isAccumulative = false
    self.active = false
    self.onRemove = onRemove
    self.data = nil
    self.thread = nil
    return self
end

function Effect:load(data)
    if self.active then 
        if not self.isReappliable then
            return
        end
        --if reappliable time resets 
        if self.thread then
            self.thread:Cancel()
        end
        --if accumulative, accumulate data except duration, otherwise simple  overwrite
        if self.isAccumulative then
            self.data = self:accumulateData(self.data, data)
        else
            self.data = data
        end
    else
        self.data = data
    end
    self.duration = data.duration or 0
    self.active = true
    self:apply(self.data)
    if not self.duration or self.duration < 0 then return end
    self.thread = task.delay(self.duration, function()
        if self.onRemove then
            self.onRemove()
        end
        self:remove()
    end)
    
end

function Effect:accumulateData(oldData, newData)
    local data = {}
    for key, value in pairs(newData) do
        if key == "duration" then continue end
        if type(value) == "number" then
            data[key] = (oldData[key] or 0) + value
        else
            data[key] = value
        end
    end
    return data
end

function Effect:forceRemove()
    self:unload()
    self:remove()
end

-- no need to remove as this is intended to be called after player left or character removed, just cancel the thread and onRemove
function Effect:unload()
    if self.thread then
        self.thread:Cancel()
    end
    if self.onRemove then
        self.onRemove()
    end
end

return Effect