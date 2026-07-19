local Bomb = require(script.Parent.Parent.projectiles.Bomb)

local SmokeBomb = {
    affectCaster = true,
    explodeOnImpact = false,
    onlyPlayers = true,
}
SmokeBomb.__index = SmokeBomb
setmetatable(SmokeBomb, {__index = Bomb})

function SmokeBomb.new(config, tool)
    local self = setmetatable(Bomb.new(config, tool), SmokeBomb)
    self.smokeRadius = config.smokeRadius or 15
    self.smokeDuration = config.smokeDuration or 10
    self.attachmentCount = config.attachmentCount or 15
    return self
end

function SmokeBomb:createSmokeEmitter(): ParticleEmitter
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "SmokeParticles"
    emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
    emitter.Lifetime = NumberRange.new(3, 8)
    emitter.Rate = 50
    emitter.SpreadAngle = Vector2.new(60, 60)
    emitter.Speed = NumberRange.new(2, 6)
    emitter.Rotation = NumberRange.new(0, 360)
    emitter.RotSpeed = NumberRange.new(-20, 20)
    -- Size progression (grow over time)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 3),
        NumberSequenceKeypoint.new(0.5, 8),
        NumberSequenceKeypoint.new(1, 12)
    })
    -- Transparency progression
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(0.3, 0.4),
        NumberSequenceKeypoint.new(0.7, 0.6),
        NumberSequenceKeypoint.new(1, 1)
    })
    emitter.Color = ColorSequence.new(
        Color3.fromRGB(180, 180, 180),
        Color3.fromRGB(120, 120, 120)
    )
    emitter.LightEmission = 0.3
    emitter.LightInfluence = 0
    emitter.ZOffset = 1
    return emitter
end

function SmokeBomb:createSmokeCloud(position: Vector3): Part
    local smokePart = Instance.new("Part")
    smokePart.Name = "SmokeCloud"
    smokePart.Size = Vector3.new(1, 1, 1)
    smokePart.Position = position + Vector3.new(0, 2, 0)
    smokePart.Anchored = true
    smokePart.CanCollide = false
    smokePart.Transparency = 1
    smokePart.Parent = workspace
    
    -- Create attachments in a circular pattern
    local attachments = {}
    for i = 1, self.attachmentCount do
        local attachment = Instance.new("Attachment")
        -- Circular distribution
        local angle = (i / self.attachmentCount) * math.pi * 2
        local distance = self.smokeRadius * 0.8
        attachment.Position = Vector3.new(
            math.cos(angle) * distance * math.random(70, 100) / 100,
            math.random(-2, 5),
            math.sin(angle) * distance * math.random(70, 100) / 100
        )
        
        attachment.Parent = smokePart
        table.insert(attachments, attachment)
        
        -- Add emitter to each attachment
        local emitter = self:createSmokeEmitter()
        emitter.Rate = math.random(40, 60)
        emitter.Lifetime = NumberRange.new(2, 7)
        emitter.Parent = attachment
    end
    
    return smokePart, attachments
end

function SmokeBomb:expandSmoke(_smokePart: Part, attachments: {Attachment})
    task.spawn(function()
        local startTime = os.clock()
        local expandTime = 2
        
        while os.clock() - startTime < expandTime do
            local progress = (os.clock() - startTime) / expandTime
            
            -- Move attachments outward gradually
            for i, attachment in ipairs(attachments) do
                local angle = (i / #attachments) * math.pi * 2
                local targetDistance = self.smokeRadius * 0.8
                local currentDistance = targetDistance * progress
                
                attachment.Position = Vector3.new(
                    math.cos(angle) * currentDistance,
                    attachment.Position.Y,
                    math.sin(angle) * currentDistance
                )
            end
            
            task.wait(0.1)
        end
    end)
end

function SmokeBomb:fadeOutSmoke(smokePart: Part, attachments: {Attachment})
    task.spawn(function()
        -- Wait before starting fade
        task.wait(self.smokeDuration - 3)
        -- Gradual fade out
        local fadeTime = 3
        local fadeStart = os.clock()
        
        while os.clock() - fadeStart < fadeTime do
            local fadeProgress = (os.clock() - fadeStart) / fadeTime
            
            -- Reduce emission rate
            for _, attachment in ipairs(attachments) do
                for _, child in ipairs(attachment:GetChildren()) do
                    if child:IsA("ParticleEmitter") then
                        child.Rate = math.floor(50 * (1 - fadeProgress))
                    end
                end
            end
            task.wait(0.2)
        end
        -- Disable all emitters
        for _, attachment in ipairs(attachments) do
            for _, child in ipairs(attachment:GetChildren()) do
                if child:IsA("ParticleEmitter") then
                    child.Enabled = false
                end
            end
        end
        -- Wait for particles to dissipate, then cleanup
        task.wait(2)
        smokePart:Destroy()
    end)
end

function SmokeBomb:onExplode(_player, impactData, _hitPlayers)
    if not impactData or not impactData.Position then
        warn("SmokeBomb: No impact position provided")
        return
    end
    --should create a part that will change the player hidden status and onLeave will change again
    -- Create smoke cloud
    local smokePart, attachments = self:createSmokeCloud(impactData.Position)
    -- Start expansion animation
    self:expandSmoke(smokePart, attachments)
    -- Start fade out after duration
    self:fadeOutSmoke(smokePart, attachments)
end

return SmokeBomb