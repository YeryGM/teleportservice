local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Checkpoint = {
    debugOn = false,
    tag = "ckpt"

}

function Checkpoint:getCheckPointInstances()
    return CollectionService:GetTagged(self.tag)
end

function Checkpoint.new(part: BasePart, updateCallback)
    local self = setmetatable({}, {__index = Checkpoint})
    self.id = nil
    self.state = false
    self.position = nil
    self.spawnCFrame = nil
    self.isGlobal = true
    self.part = part
    self.updateCallback = updateCallback
    self.conns = {}
    self:load(part)
    return self
end

function Checkpoint:load(part: BasePart)
    local id = part:GetAttribute("id")
    if not id then
        if self.debugOn then
            warn("Checkpoint part missing id attribute: " .. part.Name)
        end
        return
    else 
        assert(typeof(id) == "number", "Checkpoint id attribute must be a number: " .. part.Name)
        self.id = id
    end
    
    local notGlobal:boolean = part:GetAttribute("notGlobal") :: boolean
    if notGlobal then
        self.isGlobal = false
    end

    local position:Vector3 = part.Position
    if not position then
        if self.debugOn then
            warn("Checkpoint part missing position: " .. part.Name)
        end
        return
    else
        assert(typeof(position) == "Vector3", "Checkpoint position must be a Vector3: " .. part.Name)
        self.position = position
    end

    self.spawnCFrame = part.CFrame

    local conn = part.Touched:Connect(function(hit)
        self:onTrigger(hit)
    end)
    table.insert(self.conns, conn)
end

function Checkpoint:onTrigger(hit)
    if self.debugOn then
        warn("Checkpoint triggered for id: " .. tostring(self.id))
    end
    if self.state then
        if self.debugOn then
            warn("Checkpoint already activated for id: " .. tostring(self.id))
        end
        return
    end
    local character = hit.Parent
    local player = character and Players:GetPlayerFromCharacter(character) or nil
    if player then
        self:unload()
        self.updateCallback(player, self.id)
    end
end

function Checkpoint:unload()
    self.state = true
    for _, conn in ipairs(self.conns) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(self.conns)
    self.part:Destroy()
end

return Checkpoint