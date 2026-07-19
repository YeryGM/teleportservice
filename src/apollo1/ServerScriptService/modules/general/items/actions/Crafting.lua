local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Backpack = require(script.Parent.Backpack)
local InfoS = require(script.Parent.Parent.Parent.data.Info)
local BombList = InfoS.Bombs

local dataFolder = ReplicatedStorage.modules.general.data
local Enums = require(dataFolder.Enums)
local Info = require(dataFolder.Info)
local IngredientsList = Info.Ingredients

local itemRemotes = ReplicatedStorage.funcs.general.items
local getCraftables:RemoteFunction = itemRemotes.getCraftables
local craft:RemoteFunction = itemRemotes.craft
local canCraftItem:RemoteFunction = itemRemotes.canCraftItem
local canCraftItems:RemoteFunction = itemRemotes.canCraftItems

local Crafting = {
    debugOn = false,
}

local function getRecipe(itemId: number)
    if not BombList[itemId] then
        return nil
    end
    return BombList[itemId].recipe
end

local function isValidCraftableItem(itemId: number): boolean
    return BombList[itemId] ~= nil
end

function Crafting:load()
    getCraftables.OnServerInvoke = function(_player: Player)
        return self:getCraftables()
    end

    craft.OnServerInvoke = function(player: Player, id : number)
        return self:craftItemFixedNumber(player, id)
    end

    canCraftItem.OnServerInvoke = function(player: Player, itemId: number, amountCraft: number)
        return self:canCraftItem(player, itemId, amountCraft)
    end

    canCraftItems.OnServerInvoke = function(player: Player, itemIds: {number}, amounts: {number}?)
        return self:canCraftItems(player, itemIds, amounts)
    end
end

function Crafting:craftItemFixedNumber(player: Player, id: number)
    local amountCraft = BombList[id] and BombList[id].amount or 1
    return self:craftItem(player, id, amountCraft)
end

function Crafting:craftItem(player: Player, id: number, amountCraft: number): boolean
    if not (player and player:IsA("Player")) or not id or not amountCraft then
        return false
    end
    local itemId = id 
    local validItem = isValidCraftableItem(itemId)
    if not validItem then
        if self.debugOn then
            warn("Player " .. player.Name .. " attempted to craft invalid itemId: " .. tostring(itemId))
        end
        return false
    end
    assert(type(amountCraft) == "number", "amountCraft must be a number")
    if amountCraft <= 0 then
        if self.debugOn then
            warn("Player " .. player.Name .. " attempted to craft item with invalid amount: " .. tostring(amountCraft))
        end
        return false
    end
    local recipe = getRecipe(itemId)
    if not recipe then
        if self.debugOn then
            warn("No recipe found for itemId: " .. tostring(itemId))
        end
        return false
    end
    local canCraft = self:canCraft(player, itemId, recipe, amountCraft)
    if not canCraft then
        if self.debugOn then
            warn("Player " .. player.Name .. " attempted to craft item without required ingredients. ItemId: " .. tostring(itemId) .. " Amount: " .. tostring(amountCraft))
        end
        return false
    end
    --remove the required items from the player's inventory
    for ingredientId, ingredientData in pairs(recipe) do
        local amount = ingredientData.amount * amountCraft
        local ingredientName = IngredientsList[ingredientId].name
        Backpack:removeItem(player, ingredientName, amount)
    end
    --give the crafted item to the player, we only craft bombs -- GOTTA CHANGE LATER IF THERE ARE MOTHER TYPES OF CRAFTABLES
    -- maybe change bomb list to craftable list that has the item type in it so we know which folder to clone the tool from and etc
    local success, tools = Backpack:giveItem(player, BombList[itemId].name, amountCraft, itemId, Enums.items.types.Bomb)
    if not success or not tools or not tools[1] then
        if self.debugOn then
            warn("Failed to give crafted item to player: " .. tostring(itemId))
        end
        return false
    end
     if self.debugOn then
        print("Player " .. player.Name .. " successfully crafted itemId: " .. tostring(itemId) .. " Amount: " .. tostring(amountCraft))
    end
    return true
end

function Crafting:canCraft(player: Player, itemId: number, ownedRecipe, amountCraft: number)
    local validItem = isValidCraftableItem(itemId)
    if not validItem then
        return false
    end
    for ingredientId, ingredientData in pairs(ownedRecipe) do
        local amount = ingredientData.amount * amountCraft
        local ingredientName = IngredientsList[ingredientId].name
        if not Backpack:hasItem(player, ingredientName, amount) then
            return false
        end
    end
    return true
end
-- to know which ingredients the player is missing
function Crafting:canCraftItem(player: Player, itemId: number, amountCraft: number)
    local validItem = isValidCraftableItem(itemId)
    if not validItem then
        return nil
    end
    local recipe = getRecipe(itemId)
    if not recipe then
        return nil
    end
    local crafts = {}
    for ingredientId, ingredientData in pairs(recipe) do
        local amount = ingredientData.amount * amountCraft
        local ingredientName = IngredientsList[ingredientId].name
        if not Backpack:hasItem(player, ingredientName, amount) then
            crafts[ingredientId] = false
        else
            crafts[ingredientId] = true
        end
    end
    return crafts
end

function Crafting:canCraftItems(player:Player, ids:{number}, amounts:{number}?)
    local results = {}
    for index, itemId in ipairs(ids) do
        local amountCraft = nil
        if type(amounts) == "table" then
            amountCraft = amounts[index] or amounts[itemId]
        end
        if type(amountCraft) ~= "number" or amountCraft <= 0 then
            amountCraft = BombList[itemId] and BombList[itemId].amount or 1
        end
        local result = self:canCraftItem(player, itemId, amountCraft)
        results[itemId] = result
    end
    return results
end

function Crafting:getCraftables()
   local craftables = {}
    for itemId, _ in pairs(BombList) do
        local bombData = BombList[itemId]
        if not bombData then
            if self.debugOn then
                warn("No bomb data found for itemId: " .. tostring(itemId))
            end
            continue
        end
        local ingredientsIds = bombData.recipe
        if not ingredientsIds then
            if self.debugOn then
                warn("No recipe found for itemId: " .. tostring(itemId))
            end
            continue
        end
        local recipe = {}
        for ingredientId, ingredientData in pairs(ingredientsIds) do
            local ingredientListData = IngredientsList[ingredientId]
            local amount = ingredientData.amount
            if not ingredientListData then
                if self.debugOn then
                    warn("No ingredient data found for ingredientId: " .. tostring(ingredientId) .. " in recipe for itemId: " .. tostring(itemId))
                end
                continue
            end
            recipe[ingredientId] = {
                id = ingredientId, 
                amount = amount, 
            }
        end
        local data = { 
            id = itemId, 
            name = bombData.name, 
            amount = bombData.amount, 
            recipe = recipe
        }
        craftables[itemId] = data
    end
    return craftables
end

return Crafting