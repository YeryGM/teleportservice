local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)

local qtesFolder = script.Parent.Parent.Parent.interaction.qte
local RepeatedPress = require(qtesFolder.RepeatedPress)
local OrderedPress = require(qtesFolder.OrderedPress)

local QteC = {
    debugOn = false,
}

function QteC:load(player:Player)
    self.player = player
    self.activeQte = nil
end

function QteC:create(qteEnum:number, onSuccess, onFailure, data)
    if self.activeQte then
        self.activeQte:stop()
        self.activeQte = nil
    end
    local handler = {
        [Enums.qte.types.Repeated] = function()
            return RepeatedPress.new(onSuccess, onFailure, data, qteEnum)
        end,
        [Enums.qte.types.Sequence] = function()
            return OrderedPress.new(onSuccess, onFailure, data, qteEnum)
        end,
    }
    if not handler[qteEnum] then return end
    local qte = handler[qteEnum]()

    if not qte then return end
    self.activeQte = qte
end

function QteC:stop()
    if self.activeQte then
        self.activeQte:stop()
        self.activeQte = nil
    end
end

return QteC