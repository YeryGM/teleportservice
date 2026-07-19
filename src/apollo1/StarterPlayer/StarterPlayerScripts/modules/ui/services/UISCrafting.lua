local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CraftingActions = require(script.Parent.Parent.store.crafting.CraftingActions)
local UiActions = require(script.Parent.Parent.store.ui.UiActions)

local Info = require(ReplicatedStorage.modules.general.data.Info)
local IngredientsList = Info.Ingredients
local BombList = Info.Bombs

local craftingFolder = ReplicatedStorage.funcs.general.items
local getCraftables = craftingFolder.getCraftables
local craftItem = craftingFolder.craft
local canCraftItems = craftingFolder.canCraftItems

local CraftingService = {}

local map = {
    ingredient = 1,
    bomb = 2,
}

local function ingredientOrBomb(itemId: number): number?
    if IngredientsList[itemId] then
        return map.ingredient
    end
    if BombList[itemId] then
        return map.bomb
    end
    return nil
end

function CraftingService.selectCraftable(itemId:number)
    local state = CraftingActions.getState()
    if state.ui.selectedItemId == itemId then
        return
    end
    CraftingActions.setSelectedItem(itemId)
end

function CraftingService.loadCraftables(force:boolean)
    local state = CraftingActions.getState()
    if state.ui.loading then
        return
    end
    if state.ui.loaded and not force then
        return
    end
    CraftingActions.setLoading(true)
    CraftingActions.setError(nil)

    local ok, result = pcall(function()
        return getCraftables:InvokeServer()
    end)

    CraftingActions.setLoading(false)
    if not ok or type(result) ~= "table" then
        CraftingActions.setError("Failed to load craftables")
        return
    end

    local itemIds = {}
    local firstId = nil

    for _, item in pairs(result) do
        if item and item.id then
            table.insert(itemIds, item.id)
            if not firstId then
                firstId = item.id
            end
        end
    end

    CraftingActions.setCraftables({
        craftables = result,
        itemIds = itemIds,
    })

    CraftingActions.setLoaded(true)
    if firstId then
        CraftingActions.setSelectedItem(firstId)
    end
    CraftingService.refreshCraftInfoForItems(itemIds)
end

function CraftingService.refreshCraftInfoForItems(itemIds: {number})
    if type(itemIds) ~= "table" then
        return
    end
    if #itemIds == 0 then
        return
    end
    local state = CraftingActions.getState()
    local amounts = {}
    for _, itemId in ipairs(itemIds) do
        local craftable = state.recipes.craftables[itemId]
        local amount = craftable and craftable.amount
        if amount == nil then
            local bombData = BombList[itemId]
            amount = bombData and bombData.amount or 1
        end
        amounts[itemId] = amount
    end
    local ok, info = pcall(function()
        return canCraftItems:InvokeServer(itemIds, amounts)
    end)
    if not ok or type(info) ~= "table" then
        return
    end
    local current = state.details.craftInfo
    local nextCraftInfo = table.clone(current)
    for itemId, craftInfo in pairs(info) do
        nextCraftInfo[itemId] = craftInfo
    end
    CraftingActions.setCraftInfo(nextCraftInfo)
end

function CraftingService.craft(itemId: number)
    if not itemId then
        return false
    end
    local success = pcall(function()
        return craftItem:InvokeServer(itemId)
    end)
    if not success then
        return false
    end
    local state = CraftingActions.getState()
    CraftingService.refreshCraftInfoForItems(state.recipes.itemIds)
    return true
end

function CraftingService.updateItems(items)
    local ingredients = {}
    local bombs = {}
    for itemId, amount in pairs(items) do
        local itemType = ingredientOrBomb(itemId)
        if itemType == map.ingredient then
            ingredients[itemId] = amount
        elseif itemType == map.bomb then
            bombs[itemId] = amount
        end
    end
    CraftingActions.setIngredientsOwned(ingredients)
    CraftingActions.setBombAmounts(bombs)
    local state = CraftingActions.getState()
    CraftingService.refreshCraftInfoForItems(state.recipes.itemIds)
end

function CraftingService.open()
    UiActions.setCrafting()
    CraftingService.loadCraftables(false)
end

function CraftingService.close()
    UiActions.setGameplay()
end

return CraftingService