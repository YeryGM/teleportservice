-- FOR CONFIGS OR INFO THAT DO NOT DEPEND ON STATE
local infoFolder = script.Parent.info
local Tolls = require(infoFolder.IFTolls)
local Objectives = require(infoFolder.IFObjectives)
local Bombs = require(infoFolder.IFBombs)
local Dialogues = require(infoFolder.IFDialogues)
local Ingredients = require(infoFolder.IFIngredients)

local Info = {
    Tolls = Tolls,
    Objectives = Objectives,
    Bombs = Bombs,
    Dialogues = Dialogues,
    Ingredients = Ingredients,
}

return Info