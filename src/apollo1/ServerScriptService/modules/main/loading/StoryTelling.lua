local ServerScriptService = game:GetService("ServerScriptService")
local StoryTellers = require(ServerScriptService.modules.general.data.info.IFSSTeller)

local StoryTelling = {
    debugOn = false,
}

function StoryTelling:load(zone:string)
    local storyTeller = StoryTellers[zone]
    if storyTeller then
        if storyTeller.load then
            local success, err = pcall(function()
                storyTeller:load()
            end)
            if not success then
                warn("Failed to load storyteller for zone ", zone, ": ", tostring(err))
            end
        elseif StoryTelling.debugOn then
            warn("Storyteller for zone has no load function: " .. zone)
        end
    else
        if StoryTelling.debugOn then
            warn("No storyteller found for zone: " .. zone)
        end
    end
end
--[[ 
--story tellers should only be unlaoded by themselves
function StoryTelling.unload(zone:string)
    local storyTeller = StoryTelling.storyTellers[zone]
    if not storyTeller then
        return
    end
    if not storyTeller.unload then
        if StoryTelling.debugOn then
            warn("Storyteller for zone has no unload function: " .. zone)
        end
        return
    end

    local success, err = pcall(function()
        storyTeller:unload()
    end)
    if not success then
        warn("Failed to unload storyteller for zone ", zone, ": ", tostring(err))
    end
end
 ]]
return StoryTelling