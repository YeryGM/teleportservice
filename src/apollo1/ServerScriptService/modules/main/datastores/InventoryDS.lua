--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local DataTypes = require(ServerScriptService.modules.general.data.types.TDataStores)
local DataStore = require(script.Parent.DataStore)

type InventoryData = DataTypes.InventoryData
type InventoryItemData = DataTypes.InventoryItemData

local InventoryDS = {
    data = {
        DefaultData = {
            Items = {}
        }
    },
    playerMap = {},
    debugOn = false
}

InventoryDS.__index = InventoryDS
setmetatable(InventoryDS, { __index = DataStore })

function InventoryDS.new(rootStore, player: Player)
    local self = setmetatable(rootStore:CreateNestedStore("inve", InventoryDS.data), InventoryDS)
    self.player = player
    self.rootStore = rootStore
    self.debugOn = InventoryDS.debugOn
    InventoryDS.playerMap[player.UserId] = self
    return self
end

function InventoryDS:save(): boolean
    return self:SaveAllCached()
end

function InventoryDS:addItem(itemId: DataTypes.Id, itemData: InventoryItemData): (boolean, string?)
    if type(itemData) ~= "table" then
        return false, "Invalid item data"
    end
    return self:UpdateCachedData(self.player.UserId, function(data: InventoryData)
        if not data.Items then 
            data.Items = {}
        end
        if not data.Items[itemId] then
            data.Items[itemId] = itemData
        else
            -- If item already exists, merge data
            for key, value in pairs(itemData) do
                data.Items[itemId][key] = value
            end
        end
        return data, nil
    end)
end

function InventoryDS:deleteItem(itemId: DataTypes.Id): (boolean, string?)
    return self:UpdateCachedData(self.player.UserId, function(data: InventoryData)
        if not data.Items then return data, nil end
        data.Items[itemId] = nil
        return data, nil
    end)
end

function InventoryDS:getItem(itemId: DataTypes.Id): InventoryItemData?
    local data = self:LoadData(self.player.UserId) :: InventoryData
    return data.Items and data.Items[itemId] or nil
end

function InventoryDS:updateItem(itemId: DataTypes.Id, itemData: InventoryItemData): (boolean, string?)
    if type(itemData) ~= "table" then
        return false, "Invalid item data"
    end
    return self:UpdateCachedData(self.player.UserId, function(data: InventoryData)
        if not data.Items then 
            data.Items = {}
        end
        data.Items[itemId] = itemData
        return data, nil
    end)
end

function InventoryDS:unload()
	InventoryDS.playerMap[self.player.UserId] = nil
end

return InventoryDS