-- Each zone module should have a Load and Unload function to handle loading and unloading of the zone's content
-- Also a init to initialize any necessary data or references for the zone
local Players = game:GetService("Players")
local Modules = require(script.Parent.Modules)

local ModuleLoader = {
    activeZones = {
        --["Alleys"] = {status = true, players = {Player1, Player2}},
    }, --zones where there is at least one player
    debugOn = false,
}

function ModuleLoader.init()
    --load global services (all global services will use :load)
    for serviceName, serviceModule in pairs(Modules.globalServices) do
        if serviceModule and serviceModule.load then
            serviceModule:load()
        else
            if ModuleLoader.debugOn then
                warn("Global service module ", serviceName, " does not have a Load function.")
            end
        end
    end
    --load per zone services
    for serviceName, serviceModule in pairs(Modules.zoneServices) do
        if serviceModule.load then
            serviceModule:load(Modules.starterZone)
        else
            if ModuleLoader.debugOn then
                warn("Zone service module ", serviceName, " does not have a Load function.")
            end
        end
    end
    local starterZoneName = Modules.starterZone
    if not starterZoneName then
        if ModuleLoader.debugOn then
            warn("No starter zone defined in Modules.")
        end
        return
    end
    --init zone modules
    for zoneName, zoneInstance in pairs(Modules.zones) do
        if zoneInstance and zoneInstance.init then
            zoneInstance.init()
        end
        ModuleLoader.activeZones[zoneName] = {status = false, players = {}, serviceStatus = {}}
    end
    if not Modules.zones[starterZoneName] then
        warn("Starter zone module is missing for zone: ", starterZoneName)
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        ModuleLoader.loadZone(nil, starterZoneName, player)
    end
end

function ModuleLoader.loadZone(previousZone: number?, newZone: number, player: Player)
    if not newZone then
        if ModuleLoader.debugOn then
            warn("Previous zone or new zone is nil. Previous zone: ", previousZone, " New zone: ", newZone)
        end
        return
    end
    if previousZone == newZone then
        if ModuleLoader.debugOn then
            warn("Previous zone and new zone are identical. Zone: ", newZone)
        end
        return
    end
    if not player then
        if ModuleLoader.debugOn then
            warn("Player is nil when trying to load zone. Previous zone: ", previousZone, " New zone: ", newZone)
        end
        return
    end
    if previousZone then
        ModuleLoader.handlePreviousZone(previousZone, player)
    end
    ModuleLoader.handleNewZone(newZone, player)
end

function ModuleLoader.handlePreviousZone(previousZone: number, player: Player)
    local PreviousZone = ModuleLoader.activeZones[previousZone]
    if PreviousZone then
        --remove player from previous zone's active player list
        for i, p in ipairs(PreviousZone.players) do
            if p.UserId == player.UserId then
                table.remove(PreviousZone.players, i)
                break
            end
        end
        --if there are no more players in the previous zone, unload the zone module and set the status to false
        if #PreviousZone.players == 0 then
            ModuleLoader.unloadZone(previousZone)
        end
    end
end

function ModuleLoader.handleNewZone(newZone: number, player: Player)
    assert(newZone, "New zone is nil.")
    local NewZone = ModuleLoader.activeZones[newZone]
    if not NewZone then
        NewZone = {status = false, players = {}, serviceStatus = {}}
        ModuleLoader.activeZones[newZone] = NewZone
    elseif not NewZone.serviceStatus then
        NewZone.serviceStatus = {}
    end
    --load new zone module
    if NewZone.status then
       --this means there are already players in the new zone, so we don't need to load the module again, just add the player to the active zones list
        local playerAlreadyInZone = false
        for _, existingPlayer in ipairs(NewZone.players) do
            if existingPlayer.UserId == player.UserId then
                playerAlreadyInZone = true
                break
            end
        end
        if not playerAlreadyInZone then
            table.insert(NewZone.players, player)
        end
    else
        --this means there are no players in the new zone, so we need to load the module and add the player to the active zones list
        local zoneModule = Modules.zones[newZone]
        if not zoneModule then
            warn("No module found for zone: ", newZone)
            return
        end
        if not zoneModule.load then
            warn("Zone module for ", newZone, " does not have a Load function.")
            return
        end
        --each zone module needs to return true/false
        local success, err = pcall(function()
            return zoneModule:load() 
        end)
        if not success then
            warn("Failed to load zone module for ", newZone, ": ", tostring(err))
            return
        end
        NewZone.status = true
        NewZone.players = {player}
    end
    --load zone services for the new zone
    for serviceName, serviceModule in pairs(Modules.zoneServices) do
        if NewZone.serviceStatus[serviceName] then
            --this means the service is already active for this zone, so we don't need to load it again
            if ModuleLoader.debugOn then
                warn("Service ", serviceName, " is already active for zone ", newZone)
            end
            continue
        end
        if serviceModule and serviceModule.load then
            local success, err = pcall(function()
                return serviceModule:load(newZone)
            end)
            if success then
                NewZone.serviceStatus[serviceName] = true
            else
                warn("Failed to load zone service ", serviceName, " for zone ", newZone, ": ", tostring(err))
            end
        else
            if ModuleLoader.debugOn then
                warn("Zone service module ", serviceName, " does not have a Load function.")
            end
        end
    end
end

function ModuleLoader.unloadZone(previousZone: number)
    local PreviousZone = ModuleLoader.activeZones[previousZone]
    if not PreviousZone then
        if ModuleLoader.debugOn then
            warn("Trying to unload a zone that is not in active zones list. Previous zone: ", previousZone)
        end
        return
    end
    PreviousZone.status = false
    local zoneModule = Modules.zones[previousZone]
    if not zoneModule then
        warn("No module found for zone: ", previousZone)
        return
    end
    if not zoneModule.unload then
        warn("Zone module for ", previousZone, " does not have an Unload function.")
        return
    else
        local success, err = pcall(function()
            return zoneModule:unload() 
        end)
        if not success then
            warn("Failed to unload zone module for ", previousZone, ": ", tostring(err))
            return
        end
    end

    --unload zone services for this zone
    if not PreviousZone.serviceStatus then
        PreviousZone.serviceStatus = {}
    end
    for serviceName, serviceModule in pairs(Modules.zoneServices) do
        if PreviousZone.serviceStatus[serviceName] and serviceModule and serviceModule.unload then
            local success, err = pcall(function()
                serviceModule:unload(previousZone)
            end)
            if not success then
                warn("Failed to unload zone service ", serviceName, " for zone ", previousZone, ": ", tostring(err))
            end
            PreviousZone.serviceStatus[serviceName] = false
        end
    end
end

return ModuleLoader