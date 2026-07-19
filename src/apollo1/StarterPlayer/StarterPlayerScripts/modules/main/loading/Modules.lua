local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)
--ZONES :load
--local Chocobank = nil
--GLOBAL :load
local modulesFolder = script.Parent.Parent.Parent
local UIManager = require(modulesFolder.ui.UI)
local PurchasesC = require(modulesFolder.main.purchases.PurchasesC)
local ItemManager = require(modulesFolder.general.items.ItemManagerC)
local PlayerManager = require(modulesFolder.general.player.PlayerC)
local StoryManagerC = require(modulesFolder.main.storytelling.StoryManagerC)
--PER ZONE :load(zoneName)

local Modules = {
    starterZone = Enums.zones.Chocobank,
    zones = {
       -- [Enums.zones.Chocobank] = Chocobank,
    },
    globalServices = {
        UI = UIManager,
        Purchases = PurchasesC,
        Items = ItemManager,
        Player = PlayerManager,
        Story = StoryManagerC
    },
    zoneServices = {
     
    },

}
return Modules