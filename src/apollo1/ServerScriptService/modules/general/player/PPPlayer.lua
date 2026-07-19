local PlayerManager = require(script.Parent.PlayerManager)

local PPPlayer = {}

local attributeMap = {
    ["ph"] = function(interactedObject:BasePart, player:Player, prompt:ProximityPrompt) -- as in player hiding ph
		PlayerManager.hidePlayer(interactedObject, player, prompt)
    end,
}

function PPPlayer.load()
    -- make prompts in the zone visible/active
end

function PPPlayer.unload()
    -- make prompts in the zone invisible/inactive
end

function PPPlayer.handlePrompt(prompt:ProximityPrompt, player:Player)
    local interactedObject = prompt.Parent 
    for _, attribute in pairs(interactedObject:GetAttributes()) do
        if attributeMap[attribute] then
            attributeMap[attribute](interactedObject, player, prompt)
        end
    end
end

return PPPlayer
