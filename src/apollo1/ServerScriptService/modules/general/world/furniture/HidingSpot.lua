type HidingSpotModel = {
    insidePart: BasePart,
    outsidePart: BasePart,
    promptPart: BasePart
}

local HidingSpot = {}
HidingSpot.__index = HidingSpot

function HidingSpot.new(model: HidingSpotModel)
    local self = setmetatable({}, HidingSpot)
    self.model = model
    self.insidePart = model.insidePart
    self.outsidePart = model.outsidePart
    self.promptpart = model.promptPart
    self.debugOn = false
    self.occupied = false
    self.occupiedByUserId = nil
    self.ocupied = false
    return self
end

local function setOccupied(self, isOccupied:boolean, userId:number?)
    self.occupied = isOccupied
    self.ocupied = isOccupied
    self.occupiedByUserId = userId
end

function HidingSpot:hidePlayer(player:Player): boolean
    if not player then return false end
    if self.occupied and self.occupiedByUserId ~= player.UserId then
        if self.debugOn then
            print("Hiding spot is already occupied")
        end
        return false
    end
    local character = player.Character
    if not (character and self.insidePart) then return false end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    character:PivotTo(self.insidePart.CFrame)
    humanoidRootPart.Anchored = true
    setOccupied(self, true, player.UserId)
    self:animateClose()
    return true
end

function HidingSpot:unhidePlayer(player:Player): boolean
    if not player then return false end
    if self.occupiedByUserId and self.occupiedByUserId ~= player.UserId then
        return false
    end

    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if self.outsidePart then
            character:PivotTo(self.outsidePart.CFrame)
        end
        if humanoidRootPart then
            humanoidRootPart.Anchored = false
        end
    end

    local wasOccupied = self.occupied
    setOccupied(self, false, nil)
    if wasOccupied then
        self:animateOpen()
    end

    return true
end

function HidingSpot:animateOpen()
    --animate the hiding spot opening (e.g. closet doors) overriden by child
end

function HidingSpot:animateClose()
    --animate the hiding spot closing (e.g. closet doors) overriden by child
end

return HidingSpot