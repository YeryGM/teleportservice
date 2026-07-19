local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shop = require(script.Parent.Shop)
local Enums = require(ReplicatedStorage.modules.general.data.Enums).purchases.shopTypes
local CountDownSync = require(ReplicatedStorage.modules.general.utils.CountDown)
local CreditsDS = require(script.Parent.Parent.datastores.CreditsDS)

local remoteFuncs = ReplicatedStorage.funcs.general.purchases
local getItem:RemoteFunction = remoteFuncs.getItem
local getItems:RemoteFunction = remoteFuncs.getItems
local purchaseItem:RemoteFunction = remoteFuncs.purchaseItem
local purchaseItems:RemoteFunction = remoteFuncs.purchaseItems

local openShop:RemoteEvent = ReplicatedStorage.events.general.purchases.openShop

local countdownTime = 30

local Purchases = {
    shops = {},
	conns = {},
}

function Purchases:load()
    --load the pre shop 
    self.shops[Enums.Prerun] = Shop.new(Enums.Prerun)
    
    local conn = Players.PlayerRemoving:Connect(function(player: Player)
        for _, shop in pairs(self.shops) do
            shop:clearPlayer(player)
        end
    end)
    table.insert(self.conns, conn)
    
    getItems.OnServerInvoke = function(player:Player, shopType: number)
        local shop = self.shops[shopType]
        if not shop then
            if Shop.debugOn then
                warn(string.format("Player %s attempted to access invalid shop type %d", player.Name, shopType))
            end
            return nil
        end
        return shop:getItems()
    end

    getItem.OnServerInvoke = function(player:Player, shopType: number, itemId: number)
        local shop = self.shops[shopType]
        if not shop then
            if Shop.debugOn then
                warn(string.format("Player %s attempted to access invalid shop type %d", player.Name, shopType))
            end
            return nil
        end
        return shop:getItem(itemId)
    end

    purchaseItem.OnServerInvoke = function(player:Player, shopType: number, itemId: number, data)
        local shop = self.shops[shopType]
        if not shop then
            if Shop.debugOn then
                warn(string.format("Player %s attempted to access invalid shop type %d", player.Name, shopType))
            end
            return false
        end
        return shop:purchaseItem(player, itemId, data)
    end

    purchaseItems.OnServerInvoke = function(player:Player, shopType: number, items)
        local shop = self.shops[shopType]
        if not shop then
            if Shop.debugOn then
                warn(string.format("Player %s attempted to access invalid shop type %d", player.Name, shopType))
            end
            return false
        end
        local credits = CreditsDS.playerMap[player.UserId] 
        if not credits then
            if Shop.debugOn then
                warn(string.format("Player %s has no credits data", player.Name))
            end
            return false
        end
        local balance = credits:getBalance()
        return balance, shop:purchaseItems(player, items)
    end
end

function Purchases:start()
    local _countdownInstance = CountDownSync.new(openShop,countdownTime,nil, nil)
end


return Purchases