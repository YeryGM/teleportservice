local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)
local IFSBombs = require(script.Parent.Parent.Parent.data.info.IFSBombs)

local bombsFolder = script.Parent.Parent.bombs
local itemsRemotes = ReplicatedStorage.events.general.items
local throwBomb:RemoteEvent = itemsRemotes.throwBomb

local modules = {
    [Enums.items.bombs.Stamina] = require(bombsFolder.StaminaBomb),
    [Enums.items.bombs.Speed] = require(bombsFolder.SpeedBomb),
    [Enums.items.bombs.Smoke] = require(bombsFolder.SmokeBomb),   
    [Enums.items.bombs.Slow] = require(bombsFolder.SlowBomb),
    [Enums.items.bombs.Random] = require(bombsFolder.RandomBomb),
    [Enums.items.bombs.Poison] = require(bombsFolder.PoisonBomb),
    [Enums.items.bombs.Jump] = require(bombsFolder.JumpBomb),
    [Enums.items.bombs.Health] = require(bombsFolder.HealthBomb),
    [Enums.items.bombs.Freeze] = require(bombsFolder.FreezeBomb),
    [Enums.items.bombs.Death] = require(bombsFolder.DeathBomb),
   -- [Enums.items.bombs.Distraction] = require(bombsFolder.DistractionBomb),
}

local BombsM = {
    conns = {},
    createdBombs = {}
}

function BombsM:load()
    local conn2 = throwBomb.OnServerEvent:Connect(function(player: Player, throwData)
        self:throwBomb(player, throwData)
    end)
    table.insert(self.conns, conn2)
end

function BombsM:unload()
    for _, conn in ipairs(self.conns) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    self.conns = {}
end

function BombsM.new(itemId:number, tool: Tool)
    local bombConfig = IFSBombs[itemId]
    if not bombConfig then
        warn("Invalid bomb itemId:", itemId)
        return
    end
    local bombModule = modules[itemId]
    if not bombModule then
        warn("No module found for bomb itemId:", itemId)
        return
    end
    local bomb = bombModule.new(bombConfig, tool)
    local uid = bomb:getUid()
    BombsM.createdBombs[uid] = bomb
    return bomb
end

function BombsM:throwBomb(player: Player, throwData)
    if not throwData or not throwData.direction or not throwData.uid then
         warn("Invalid throw data received from player", player.Name)
        return
    end
    local bomb = self.createdBombs[throwData.uid]
    if bomb then
        bomb:Throw(player, throwData)
    end
end

return BombsM