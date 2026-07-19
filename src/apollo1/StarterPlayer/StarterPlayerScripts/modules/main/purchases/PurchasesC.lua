local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local PlayerScripts = Player.PlayerScripts
local uiServices = PlayerScripts.modules.ui.services
local UISShop = require(uiServices.UISShop)

local playerRemotes = ReplicatedStorage.events.general.player
local waitingFinishedEvent: RemoteEvent = playerRemotes.waitingFinished
local playerCountUpdateEvent: RemoteEvent = playerRemotes.playerCountUpdate
local openShop:RemoteEvent = ReplicatedStorage.events.general.purchases.openShop

local PurchasesC = {
    conns = {},
    onetimeConns = {},
}


function PurchasesC:load()
    local function onOpenShop(shopData)
        UISShop.open(shopData)
        self.onetimeConns.openShop:Disconnect()
        self.onetimeConns.openShop = nil
    end

    local function onWaitingFinished()
        UISShop.close()
        self.onetimeConns.waitingFinished:Disconnect()
        self.onetimeConns.waitingFinished = nil
    end

    local conn = openShop.OnClientEvent:Connect(function(shopData)
        onOpenShop(shopData)
    end)
    table.insert(self.conns, conn)
    self.onetimeConns.openShop = conn

    local conn2 = playerCountUpdateEvent.OnClientEvent:Connect(function(playerCount, waitingCount)
        UISShop.updateCounts({
            playerCount = playerCount,
            waitingCount = waitingCount,
        })
    end)
    table.insert(self.conns, conn2)

    local conn3 = waitingFinishedEvent.OnClientEvent:Connect(function()
        onWaitingFinished()
    end)
    table.insert(self.conns, conn3)
    self.onetimeConns.waitingFinished = conn3
end

function PurchasesC:unload()
    for _, conn in pairs(self.conns) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    for _, conn in pairs(self.onetimeConns) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    self.conns = {}
    self.onetimeConns = {}
end

return PurchasesC