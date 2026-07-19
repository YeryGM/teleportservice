local Effect = require(script.Parent.Effect)

local FreezeEffect = {
    isReappliable = true,
    isAccumulative = false,
}
FreezeEffect.__index = FreezeEffect
setmetatable(FreezeEffect, {__index = Effect})

function FreezeEffect.new(player: Player, onRemove)
    local self = setmetatable(Effect.new(player, onRemove), FreezeEffect)
    self.originalData = {
        parts = {}
    }
    return self
end

function FreezeEffect:apply(data)
    if not self.player.Character or not self.player.Character.Humanoid then return end
    self.originalData.walkSpeed = self.player.Character.Humanoid.WalkSpeed
    self.player.Character.Humanoid.WalkSpeed = data.walkSpeed or 0
    self:applyFreezeVisual(self.player.Character)
end

function FreezeEffect:remove()
    if not self.player.Character or not self.player.Character.Humanoid then return end
    self.player.Character.Humanoid.WalkSpeed = self.originalData.walkSpeed
    self:removeFreezeVisual(self.player.Character)
end

function FreezeEffect:applyFreezeVisual(character)
    for _, part in ipairs(character:GetDescendants()) do
        self.originalData.parts[part] = {
            BrickColor = part.BrickColor,
            Material = part.Material,
        }
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.BrickColor = BrickColor.new("Light blue")
            part.Material = Enum.Material.Ice
        end
    end
end

function FreezeEffect:removeFreezeVisual(character)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local originalPartData = self.originalData.parts[part]
            if originalPartData then
                part.BrickColor = originalPartData.BrickColor
                part.Material = originalPartData.Material
            else
                part.BrickColor = BrickColor.new("Medium stone grey")
                part.Material = Enum.Material.Plastic
            end
        end
    end
end

return FreezeEffect