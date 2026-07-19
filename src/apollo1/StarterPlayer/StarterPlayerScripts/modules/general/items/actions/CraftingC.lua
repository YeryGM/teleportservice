local Player = game:GetService("Players").LocalPlayer
local PlayerScripts = Player.PlayerScripts
local uiServices = PlayerScripts.modules.ui.services
local CraftingService = require(uiServices.UISCrafting)

local itemEvents = PlayerScripts.events.general.items
local backPackChangedEvent:BindableEvent = itemEvents.backPackChanged

local CraftingC = {
    conns = {},
    loaded = false,
}

function CraftingC:load()
    if self.loaded then 
        return
    end
    local conn = backPackChangedEvent.Event:Connect(function(items)
        CraftingService.updateItems(items)
    end)
    table.insert(self.conns, conn)

    self.loaded = true
end

function CraftingC:unload()
    if not self.loaded then 
        return
    end
    for _, conn in pairs(self.conns) do
        conn:Disconnect()
    end
    self.conns = {}
    self.loaded = false
end

function CraftingC:openCrafting()
    CraftingService.open()
end

function CraftingC:closeCrafting()
    CraftingService.close()
end

return CraftingC