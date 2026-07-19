local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Enums = require(ReplicatedStorage.modules.general.data.Enums)

local generalModules = ServerScriptService.modules.general
local mainModules = ServerScriptService.modules.main
--ZONES use :load
local Chocobank = nil
--GLOBAL:load
local DataManager = require(mainModules.datastores.DataManager)
local Progression = require(mainModules.progression.Progression)
local PlayerManager = require(generalModules.player.PlayerManager)
local ItemManager = require(generalModules.items.ItemManager)
local StoryManager = require(mainModules.storytelling.StoryManager)
local LobbyManager = require(mainModules.lobby.LobbyManager)
--PER ZONE:load(zoneName)
local ProximityPrompts = require(script.Parent.ProximityPrompts)
local StoryTelling = require(script.Parent.StoryTelling)

local Modules = {
    --here do the module references
    starterZone = Enums.zones.Workers,
    zones = {
        [Enums.zones.Chocobank] = Chocobank,
    },
    globalServices = {
        DataManager = DataManager,
        Progression = Progression,
        PlayerManager = PlayerManager,
        ItemManager = ItemManager,
        StoryManager = StoryManager,
        LobbyManager = LobbyManager,
    },
    zoneServices = {
       ProximityPrompts = ProximityPrompts,
       StoryTelling = StoryTelling,
    },

}
return Modules