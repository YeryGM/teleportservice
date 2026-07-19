--!strict
local DatastoreModule = require(script.Parent.DataStore)

local CreditsDS = require(script.Parent.CreditsDS)
local InventoryDS = require(script.Parent.InventoryDS)
local AchievementsDS = require(script.Parent.AchieveDS)
local StatsDS = require(script.Parent.StatsDS)
local StoryDS = require(script.Parent.StoryDS)

local stores = {
    Credits = CreditsDS,
    Inventory = InventoryDS,
    Achievements = AchievementsDS,
    Stats = StatsDS,
    Story = StoryDS
}

local PlayerDS = {
    defaultData = {
        UseScopes = true,
        AutoSave = true,
        SaveInterval = 60
    },
    playerMap = {},
    debugOn = false,
}

PlayerDS.__index = PlayerDS
setmetatable(PlayerDS, {__index = DatastoreModule})

function PlayerDS.new(player: Player)
    local self = setmetatable(DatastoreModule.new("player", PlayerDS.defaultData, nil, nil), PlayerDS)
    self.player = player
    self.stores = {}
    self.debugOn = PlayerDS.debugOn
    self:load(player)
    PlayerDS.playerMap[player.UserId] = self
    return self
end

function PlayerDS:load(player:Player)
    for _storeName, storeModule in pairs(stores) do
        table.insert(self.stores, storeModule.new(self, player))
    end
end

function PlayerDS:save(): boolean
    local success = true
    if not self:SaveAllCached() then
        success = false
    end
    for _storeName, store in pairs(self.stores) do
        if not store:save() then
            success = false
        end
    end
    return success
end

function PlayerDS:unload()
    DatastoreModule.unload(self)
    PlayerDS.playerMap[self.player.UserId] = nil
end
return PlayerDS