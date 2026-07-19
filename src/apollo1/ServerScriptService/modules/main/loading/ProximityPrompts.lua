local ProximityPromptService = game:GetService("ProximityPromptService")
local ServerScriptService = game:GetService("ServerScriptService")
local PPS = require(ServerScriptService.modules.general.data.info.IFSPP)
local ProximityPrompt = {
    debugOn = false,
    loaded = false,
}

function ProximityPrompt:globalsLoad()
    for zone, zoneModule in pairs(PPS.general) do
        if zoneModule and zoneModule.load then
            local success, err = pcall(function()
                zoneModule.load(zone)
            end)
            if not success then
                warn("Failed to load proximity prompt zone: ", tostring(err))
            end
        else
            if ProximityPrompt.debugOn then
                warn("Zone module ", zone, " does not have a Load function.")
            end
        end
    end
end

function ProximityPrompt:globalsUnload()
    for zone, zoneModule in pairs(PPS.general) do
        if zoneModule and zoneModule.unload then
            local success, err = pcall(function()
                zoneModule.unload(zone)
            end)
            if not success then
                warn("Failed to unload proximity prompt zone: ", tostring(err))
            end
        else
            if ProximityPrompt.debugOn then
                warn("Zone module ", zone, " does not have an Unload function.")
            end
        end
    end
end

function ProximityPrompt:load(zone: string)
    if not self.loaded then
        self:globalsLoad()
        self.loaded = true
    end
    local ZonePP = PPS.zones[zone]
    if not ZonePP or not ZonePP.load then
        if ProximityPrompt.debugOn then
            warn("No config found for zone ", zone)
        end
        return
    end
    local success, err = pcall(function()
        ZonePP.load()
    end)
    if not success then
        warn("Failed to load proximity prompt zone: ", tostring(err))
    end
end

function ProximityPrompt:unload(zone: string)
   local ZonePP = PPS.zones[zone]
    if not ZonePP or not ZonePP.unload then
        if ProximityPrompt.debugOn then
            warn("No config found for zone ", zone)
        end
        return
    end
    local success, err = pcall(function()
        ZonePP.unload()
    end)
    if not success then
        warn("Failed to unload proximity prompt zone: ", tostring(err))
    end
end

ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, player: Player)
    local interactedObject = prompt.Parent
    if not interactedObject then
        if ProximityPrompt.debugOn then
            warn("Proximity prompt has no parent object. Prompt: ", prompt)
        end
        return
    end
    local z = prompt:GetAttribute('z')
    local zone = PPS.zones[z]
    if not zone or not zone.handlePrompt then
        if ProximityPrompt.debugOn then
            warn("No zone found for proximity prompt or zone does not have a handlePrompt function. Prompt: ", prompt)
        end
        return
    end
    local success, err = pcall(function()
        zone.handlePrompt(prompt, player)
    end)
    if not success then
        warn("Failed to process proximity prompt trigger: ", tostring(err))
    end
end)

return ProximityPrompt