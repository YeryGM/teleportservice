local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)

local Info = require(script.Parent.Parent.data.Info)
local BombsM = require(script.Parent.bombs.BombsM)
local Crafting =require(script.Parent.actions.Crafting)
local Backpack = require(script.Parent.actions.Backpack)

local ItemManager = {}

function ItemManager:load()
    BombsM:load()
    Crafting:load()
end

function ItemManager:unload()
    BombsM:unload()
    
end

function ItemManager:addItem(player: Player, quantity: number, itemId: number, type:number)
    if not player or not quantity or not itemId then
        if self.debugOn then
            warn("Invalid parameters provided to addItem: " .. tostring(player) .. ", " .. tostring(quantity) .. ", " .. tostring(itemId))
        end
        return
    end
    local validType = false
    for _, itemType in pairs(Enums.items.types) do
        if type == itemType then
            validType = true
            break
        end
    end
    if not validType then
        if self.debugOn then
            warn("Invalid item type provided to addItem: " .. tostring(type))
        end
        return
    end
    local itemName = (Info.Bombs[itemId] and Info.Bombs[itemId].name) or 
        (Info.Consumables[itemId] and Info.Consumables[itemId].name)
    if not itemName then
        if self.debugOn then
            warn("Invalid itemId provided to addItem: " .. tostring(itemId))
        end
        return
    end
    return Backpack:giveItem(player, itemName, quantity, itemId, type)
end

return ItemManager
