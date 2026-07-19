local ReplicatedStorage = game:GetService("ReplicatedStorage")
local itemsFolder = ReplicatedStorage.events.general.items
local throwBomb:RemoteEvent = itemsFolder.throwBomb

local ThrowableClient = require(script.Parent.ThrowableC)

local BombC = {}

function BombC.new(config,tool: Tool)
    if not tool or not config then
        error("Tool and config are required to create a BombC")
    end
    local uid = tool:GetAttribute("uid")
    local self = setmetatable(ThrowableClient.new(config, uid, throwBomb), {__index = BombC})
    self.tool = tool
    self:load()
    return self
end

function BombC:load()
    local conn = self.tool.Equipped:Connect(function()
        self:Equip()
    end)

    local conn2 = self.tool.Unequipped:Connect(function()
        self:Unequip()
    end)
    table.insert(self.conns, conn)
    table.insert(self.conns, conn2)
end

return BombC