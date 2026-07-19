local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.modules.general.data.Enums)
local qteFolder = script.Parent.Parent.Parent.interaction.qte
local qtes = {
    [Enums.qte.types.RepeatedPress] = require(qteFolder.RepeatedPress),
    [Enums.qte.types.Sequence] = require(qteFolder.OrderedPress),
}

local Qteing = {
    activeQtes = {
        --[player.UserId] = true/false
    },
    debugOn = false,
}

function Qteing:createQte(player:Player, qteEnum:number, qteData , forceCreate:boolean)
    local activeQte = self.activeQtes[player.UserId]
    if activeQte then
        if not forceCreate then return end
        self:removeQte(player)
    end
    local qteModule = qtes[qteEnum]
    if not qteModule then
        if self.debugOn then
            warn("QTE type not found: "..qteEnum)
        end
        return
    end
    self.activeQtes[player.UserId] = true
    return qteModule.new(player, qteData.onSuccess, qteData.onFailure, qteData.configKey)

end

function Qteing:removeQte(player:Player)
    if not self.activeQtes[player.UserId] then
        return
    end
    self.activeQtes[player.UserId] = false
end

function Qteing:createAll(players: {Player}, qteEnum:number, qteData, forceCreate:boolean)
    for _, player in ipairs(players) do
        self:createQte(player, qteEnum, qteData, forceCreate)
    end
    
end

function Qteing:removeAll(players: {Player})
    for _, player in ipairs(players) do
        self:removeQte(player)
    end
end

return Qteing