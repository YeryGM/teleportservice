local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.modules.general.data.Enums)

local furniture = script.Parent.Parent.Parent.world.furniture
local HidingSpotsModules = { -- contains all of the hiding spot modules, indexed by the name of the hiding spot model
    --["HidingSpotModelName"] = require(path.to.hidingSpotModule),
    [Enums.furniture.Closet] = require(furniture.Closet),
}

local hideEvent: RemoteEvent = ReplicatedStorage.events.general.player.hide

local defaults = {
    hideTime = 3, -- time it takes for the player to fully hide, in seconds
}

local Hiding = {
    debugOn = false,
    hidingInfo = {}, -- indexed by player.UserId, contains the hiding spot model and prompt the player is currently using
    hidingSpots = {},
   
}

local function setCharacterState(character, newState)
	if character:GetAttribute("st") ~= newState then
		character:SetAttribute("st", newState)
		if Hiding.debugOn then 
			print("Hiding state changed to:", newState)
		end
        return true
    else 
        if Hiding.debugOn then 
            print("State is already", newState)
		end
        return false
	end
end

function Hiding:hide(player:Player, prompt:ProximityPrompt, hidingSpot:Model): boolean
    if not player or not prompt or not hidingSpot then
        return false
    end
    if not prompt:IsA("ProximityPrompt") or not hidingSpot:IsA("Model") then
        return false
    end
    local character = player.Character
	if not character then
        return false
    end
    local hidingData = self.hidingInfo[player.UserId]
    if hidingData then
        return false
    end -- player is already hiding
    local hidingSpotModule = HidingSpotsModules[hidingSpot:GetAttribute("id")]
    if not hidingSpotModule then
        if self.debugOn then
            warn("No hiding spot module found for model:", hidingSpot.Name)
        end
        return false
    end

    local spotKey = hidingSpot
    local instance = self.hidingSpots[spotKey]
    if not instance then
        instance = hidingSpotModule.new(hidingSpot)
        self.hidingSpots[spotKey] = instance
    end
    if not instance:hidePlayer(player) then
        return false
    end
    prompt.Enabled = false
    self.hidingInfo[player.UserId] = {
        model = hidingSpot,
        prompt = prompt,
        hidingInstance = instance,
    }
    local ht = defaults.hideTime -- or time defined by animation
	hideEvent:FireClient(player, {shouldHide = true, hidingSpot = hidingSpot, hideTime = ht })
	--update char state for NPC detection
	setCharacterState(character, Enums.player.states.Hiding)
	task.delay(ht, function()
		if character and character:GetAttribute("st") == Enums.player.states.Hiding then
			setCharacterState(character, Enums.player.states.Hidden)
		end
	end)
    return true
end

function Hiding:unhide(player:Player): boolean
    if not player then
        return false
    end
    local hidingData = self.hidingInfo[player.UserId]
    if not hidingData then
        return false
    end
    local character = player.Character
    if not character then
        return false
    end
    self.hidingInfo[player.UserId] = nil
    setCharacterState(character, Enums.player.states.Walk )

    if hidingData.prompt and hidingData.prompt.Parent then
        hidingData.prompt.Enabled = true
    end
    if hidingData.hidingInstance and hidingData.hidingInstance.unhidePlayer then
        hidingData.hidingInstance:unhidePlayer(player)
    end

    return true
end

return Hiding