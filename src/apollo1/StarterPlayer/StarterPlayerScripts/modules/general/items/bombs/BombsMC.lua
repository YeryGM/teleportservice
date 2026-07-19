local ReplicatedStorage = game:GetService("ReplicatedStorage")
local generalFolder = ReplicatedStorage.modules.general
local BombList = require(generalFolder.data.info.IFBombs)
local BombC = require(script.Parent.Parent.bombs.BombC)

local BombsMC = {}

function BombsMC.new(itemId: number, tool: Tool)
    if not tool or not itemId then
        error("Tool and itemId are required to create a BombsMC")
    end
    local config = BombList[itemId].config
    if not config then
        return nil
    end
    --local uid = tool:GetAttribute("uid")
    return BombC.new(config, tool)
end

return BombsMC