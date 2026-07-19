local infoFolder = script.Parent.info
local Bombs = require(infoFolder.IFSBombs)
local Effects = require(infoFolder.IFSEffects)
local Consumables = require(infoFolder.IFSConsumables)

local Info = {
    Bombs = Bombs,
    EffectList = Effects,
    Consumables = Consumables,
}
return Info