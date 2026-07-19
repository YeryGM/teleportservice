local Modules = require(script.Parent.Modules)

local ModuleLoader = {
    activeZones = {},
    debugOn = false,
    listeners = {},
    nextListenerId = 0,
}

local function notifyZoneChanged(previousZone:number?, newZone:number)
    for _, listener in pairs(ModuleLoader.listeners) do
        listener(previousZone, newZone)
    end
end

function ModuleLoader.subscribe(listener)
    ModuleLoader.nextListenerId += 1
    local id = ModuleLoader.nextListenerId
    ModuleLoader.listeners[id] = listener
    return function()
        ModuleLoader.listeners[id] = nil
    end
end

function ModuleLoader.init()
    -- load global services (if present)
    for serviceName, serviceModule in pairs(Modules.globalServices or {}) do
        if serviceModule and serviceModule.load then
            local ok, err = pcall(function()
                return serviceModule:load()
            end)
            if not ok then
                warn("Failed to load global service ", serviceName, ": ", tostring(err))
            end
        else
            if ModuleLoader.debugOn then
                warn("Global service module ", serviceName, " does not have a Load function.")
            end
        end
    end

    -- prepare zone services (some clients may want to pre-initialize services for the starter zone)
    for serviceName, serviceModule in pairs(Modules.zoneServices or {}) do
        if serviceModule and serviceModule.load then
            local ok, err = pcall(function()
                return serviceModule:load(Modules.starterZone)
            end)
            if not ok then
                warn("Failed to load zone service ", serviceName, " for starter zone: ", tostring(err))
            end
        else
            if ModuleLoader.debugOn then
                warn("Zone service module ", serviceName, " does not have a Load function.")
            end
        end
    end

    -- init zone modules and populate activeZones structure
    for zoneName, zoneInstance in pairs(Modules.zones or {}) do
        if zoneInstance and zoneInstance.init then
            pcall(function()
                zoneInstance:init()
            end)
        end
        ModuleLoader.activeZones[zoneName] = {status = false, serviceStatus = {}}
    end

    local starterZoneName = Modules.starterZone
    if not starterZoneName then
        if ModuleLoader.debugOn then
            warn("No starter zone defined in Modules.")
        end
        return
    end
    if not Modules.zones[starterZoneName] then
        warn("Starter zone module is missing for zone: ", starterZoneName)
        return
    end

    -- load starter zone for the local player
    ModuleLoader.loadZone(nil, starterZoneName)
end

function ModuleLoader.loadZone(previousZone: number?, newZone: number)
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
    if previousZone then
        ModuleLoader.unloadZone(previousZone)
    end
    ModuleLoader.handleNewZone(newZone)
    local active = ModuleLoader.activeZones[newZone]
    if active and active.status then
        notifyZoneChanged(previousZone, newZone)
    end
end

function ModuleLoader.handleNewZone(newZone: number)
    assert(newZone, "New zone is nil.")
    local NewZone = ModuleLoader.activeZones[newZone]
    if not NewZone then
        NewZone = {status = false, serviceStatus = {}}
        ModuleLoader.activeZones[newZone] = NewZone
    elseif not NewZone.serviceStatus then
        NewZone.serviceStatus = {}
    end

    if not NewZone.status then
        local zoneModule = Modules.zones[newZone]
        if not zoneModule then
            warn("No module found for zone: ", newZone)
            return
        end
        if not zoneModule.load then
            warn("Zone module for ", newZone, " does not have a Load function.")
            return
        end
        local success, err = pcall(function()
            return zoneModule:load()
        end)
        if not success then
            warn("Failed to load zone module for ", newZone, ": ", tostring(err))
            return
        end
        NewZone.status = true
    end

    -- load zone services for the new zone
    for serviceName, serviceModule in pairs(Modules.zoneServices or {}) do
        if NewZone.serviceStatus[serviceName] then
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

    -- unload zone services for this zone
    if not PreviousZone.serviceStatus then
        PreviousZone.serviceStatus = {}
    end
    for serviceName, serviceModule in pairs(Modules.zoneServices or {}) do
        if PreviousZone.serviceStatus[serviceName] and serviceModule and serviceModule.unload then
            local success, err = pcall(function()
                return serviceModule:unload(previousZone)
            end)
            if not success then
                warn("Failed to unload zone service ", serviceName, " for zone ", previousZone, ": ", tostring(err))
            end
            PreviousZone.serviceStatus[serviceName] = false
        end
    end
end

return ModuleLoader