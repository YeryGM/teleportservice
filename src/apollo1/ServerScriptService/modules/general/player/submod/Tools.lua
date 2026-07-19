local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local general = ReplicatedStorage.modules.general
local ToolListener = require(general.items.ToolListener)
local Enums = require(general.data.Enums)

local items = ServerScriptService.modules.general.items
local BombsM = require(items.bombs.BombsM)
local Consumable = require(items.consumables.Consumable)

local BackpackchangedEvent:BindableEvent = ServerScriptService.events.general.items.backPackChanged

local Tools = {
    modules = {
        [Enums.items.types.Bomb] = {
            new = function(tool:Tool, itemId: number)
                return BombsM.new(itemId, tool)
            end,
        },
        [Enums.items.types.Consumable] = {
            new = function(tool:Tool, itemId: number)
                return Consumable.new(tool, itemId)
            end,
        },
    },
    debugOn = false,
}
Tools.__index = Tools

function Tools.new(player:Player)
    local self = setmetatable(ToolListener.new(player, Tools.modules, BackpackchangedEvent), Tools)
    return self
end

return Tools