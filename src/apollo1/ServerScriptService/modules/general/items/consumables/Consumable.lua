--local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local general = ServerScriptService.modules.general
local Consumables = require(general.data.Info).Consumables
local Backpack = require(general.items.actions.Backpack)

local bindableEvent = ServerScriptService.events.general.player
local applyEffect: BindableEvent = bindableEvent.applyEffect

local Consumable = {
    conns = {},
    debugOn = false
}
Consumable.__index = Consumable

function Consumable.new(tool:Tool, id:number)
    local self = setmetatable({}, Consumable)
    self.tool = tool
    self.id = id
    self:load()
    return self
end

function Consumable:load()
    local conn = self.tool.Activated:Connect(function()
        local player = Players:GetPlayerFromCharacter(self.tool.Parent)
        if not player then return end
        self:consume(player, self.id)
    end)
    table.insert(self.conns, conn)
    local conn2 = self.tool.Unequipped:Connect(function()
    end)
    table.insert(self.conns, conn2)
end

function Consumable:unload()
    for _, conn in ipairs(self.conns) do
        if conn then
            conn:Disconnect()
        end
    end
    self.conns = {}
end

function Consumable:consume(player: Player, consumableId: number)
    local effects = Consumables[consumableId] and Consumables[consumableId].effects
    if not effects then
        if self.debugOn then
            warn("Consumable: No effects found for consumableId", consumableId)
        end
        return
    end
    local removed = Backpack:removeItem(player, self.tool.name, 1)
    if not removed then
        if self.debugOn then
            warn("Consumable: Failed to remove item from backpack for player", player.Name)
        end
        return
    end
    for _, effectId in ipairs(effects) do
        applyEffect:Fire(player, effectId, Consumables[consumableId].data)
    end
end

return Consumable
