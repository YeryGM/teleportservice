local ServerScriptService = game:GetService("ServerScriptService")
local dataFolder = ServerScriptService.modules.general.data
local types = require(dataFolder.enums.EPurchases)
local Caller = require(script.Parent.Caller)

local shops = {
    [types.Shops.Prerun] = {
        [1] = {548, 549, 550},
        [2] = {551, 552, 553},

    }, -- products ids
    [types.Shops.Vending] = {
        [1] = {554, 555, 556},
        [2] = {557, 558, 559},
    },
}

local limits = {
    amount = {
        min = 1,
        max = 100,
    },
}

local Shop = {
    debugOn = true,
}

local function getMaxPerPlayer(itemData)
    if itemData.MaxPurchasesPerPlayer ~= nil then
        return itemData.MaxPurchasesPerPlayer
    end
    if itemData.MaxPerPlayer ~= nil then
        return itemData.MaxPerPlayer
    end
    return -1
end

function Shop.new(type:number , forceId:number?)
    local self = setmetatable({}, {__index = Shop})
    self.type = type
    self.ids = {}
    self.items = {}
    self.safeItems = {}
    self.stock = {}
    self.stockPerPlayer = {}
    self:load(type, forceId)
    return self
end

function Shop:load(shopType:number, forceId:number?)
    local shopData = shops[shopType]
    if not shopData then
        if Shop.debugOn then
            warn(string.format("Attempted to load invalid shop type %d", shopType))
        end
        return
    end

    local ids = {}
    if forceId and shopData[forceId] then
        ids = shopData[forceId] 
    else
        ids = shopData[math.random(1, #shopData)]
    end
    self.ids = ids

    local items = Caller.getItems(ids) or {}
    self.items = items
    local safeItems = Caller.getSafeItems(ids) or {}
    self.safeItems = safeItems

    for itemId, itemData in pairs(items) do
        local stockValue = itemData.Stock
        if stockValue == -1 then
            self.stock[itemId] = -1
        elseif type(stockValue) ~= "number" or stockValue <= 0 then
            self.stock[itemId] = 0
        else
            self.stock[itemId] = stockValue
        end
    end
end

function Shop:getItems()
    return self.safeItems
end

function Shop:getItem(id: number)
    local item = self.safeItems[id]
    if not item then
        if Shop.debugOn then
            warn(string.format("Requested info for invalid product ID %d", id))
        end
        return nil
    end
    return item
end

function Shop:updateStock(itemId: number, amount: number)
    if self.stock[itemId] and self.stock[itemId] ~= -1 then
        self.stock[itemId] = self.stock[itemId] - amount
    end
end

function Shop:updateStockPerPlayer(player: Player, itemId: number, amount: number)
    if not self.stockPerPlayer[player.UserId] then
        self.stockPerPlayer[player.UserId] = {}
    end
    if not self.stockPerPlayer[player.UserId][itemId] then
        local maxPerPlayer = getMaxPerPlayer(self.items[itemId] or {})
        if maxPerPlayer == -1 then
            self.stockPerPlayer[player.UserId][itemId] = -1
        else
            self.stockPerPlayer[player.UserId][itemId] = maxPerPlayer - amount
        end
    else
        if self.stockPerPlayer[player.UserId][itemId] ~= -1 and self.stockPerPlayer[player.UserId][itemId] >= amount then
            self.stockPerPlayer[player.UserId][itemId] = self.stockPerPlayer[player.UserId][itemId] - amount
        end
    end
end

function Shop:clearPlayer(player: Player)
    if player then
        self.stockPerPlayer[player.UserId] = nil
    end
end

function Shop:purchaseItem(player:Player, itemId: number, data)
    data = data or {}
    local amount = data.amount or 1
    if type(amount) ~= "number" or amount < limits.amount.min or amount > limits.amount.max then
        return false
    end
    local itemData = self.items[itemId]
    if not itemData then
        if Shop.debugOn then
            warn(string.format("Attempted to purchase invalid item ID %d", itemId))
        end
        return false
    end

    local therestock = nil
    local stockAmount = self.stock[itemId] or -1
    if stockAmount == -1 then
        therestock = true
    else
        therestock =  (self.stock[itemId] - amount >= 0)
    end
    local playerStockAmount = self.stockPerPlayer[player.UserId] and self.stockPerPlayer[player.UserId][itemId] 
    if not playerStockAmount then
        playerStockAmount = getMaxPerPlayer(itemData)
    end
    local therestockPerPlayer = nil
    if playerStockAmount == -1 then
        therestockPerPlayer = true
    else
        therestockPerPlayer = (playerStockAmount - amount >= 0)
    end
    local canPurchaseAmount = therestock and therestockPerPlayer
    if not canPurchaseAmount then
        return false
    end
    local purchased, _purchaseData = Caller.processItemPurchase(player, itemId, data)
    if purchased and itemData.Type ~= types.Types.DevProduct then
        self:updateStock(itemId, amount)
        self:updateStockPerPlayer(player, itemId, amount)
    end
    return purchased
end

function Shop:purchaseItems(player:Player, items)
    for itemId, amount in pairs(items) do
        if not self:purchaseItem(player, itemId, {amount = amount}) then
            return false
        end
    end
    return true
end

return Shop