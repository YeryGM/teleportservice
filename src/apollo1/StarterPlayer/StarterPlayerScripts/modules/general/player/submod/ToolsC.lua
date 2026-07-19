local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local PlayerScripts = Player.PlayerScripts

local generalFolder = ReplicatedStorage.modules.general
local ToolListener = require(generalFolder.items.ToolListener)
local Enums = require(generalFolder.data.Enums)

local BombsMC = require(script.Parent.Parent.Parent.items.bombs.BombsMC)

local itemEvents = PlayerScripts.events.general.items
local backpackChanged: BindableEvent = itemEvents.backPackChanged

local Tools = {
    modules = {
        [Enums.items.types.Bomb] =  { 
            new = function(tool:Tool, itemId: number)
                return BombsMC.new(itemId, tool)
            end,
        },

    },
    debugOn = false,
}

function Tools.new(player:Player)
    local self = setmetatable(ToolListener.new(player, Tools.modules, backpackChanged), {__index = Tools})
    return self
end

return Tools