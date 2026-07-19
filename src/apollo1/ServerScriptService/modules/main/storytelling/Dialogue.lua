local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dialogues = require(ReplicatedStorage.modules.general.data.info.IFDialogues)

local storyRemoteEvents = ReplicatedStorage.events.general.storytelling
local dialogue:RemoteEvent = storyRemoteEvents.dialogue

local Dialogue = {
    debugOn = false,
}

local function verifyDialogueId(dialogueId:number): boolean
    if type(dialogueId) ~= "number" then
        if Dialogue.debugOn then
            warn("Dialogue ID must be a number. Received: " .. tostring(dialogueId))
        end
        return false
    end
    if not Dialogues[dialogueId] then
        if Dialogue.debugOn then
            warn("Dialogue ID " .. dialogueId .. " does not exist in Dialogues config.")
        end
        return false
    end
    return true
end

function Dialogue.play(dialogueId:number, options, player:Player?)
    if not verifyDialogueId(dialogueId) then
        return
    end
    if player then
        dialogue:FireClient(player, dialogueId, options)
    else
        dialogue:FireAllClients(dialogueId, options)
    end
end

return Dialogue