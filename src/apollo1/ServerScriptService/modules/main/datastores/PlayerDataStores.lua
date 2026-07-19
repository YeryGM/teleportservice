local PlayerDataStores = {
    datastores = {
		PlayerDS =  require(script.Parent.PlayerDS),
		PurchaseDS = require(script.Parent.PurchaseDS)
	},
}

function PlayerDataStores.new(player: Player)
    if not player then
        warn("called without a player")
        return nil
    end
    local self = setmetatable({}, {__index = PlayerDataStores})
    self.ds = {}
    self:load(player)
    return self
end

function PlayerDataStores:load(player: Player)
    for name, dsModule in pairs(self.datastores) do
        local moduleInstance = dsModule.new(player)
        self.ds[name] = moduleInstance
    end
end

function PlayerDataStores:save()
    for _, ds in pairs(self.ds) do
        ds:save()
    end
end

function PlayerDataStores:unload()
    for _, ds in pairs(self.ds) do
        if ds.unload then
            ds:unload()
        end
    end
    self.ds = {}
end
   
return PlayerDataStores