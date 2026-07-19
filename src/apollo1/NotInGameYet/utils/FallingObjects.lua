local FallingGrid = require(script.Parent.FallingGrid)
local TweenService = game:GetService("TweenService")

local FallingObjects = {}

function FallingObjects.new(spawnParts: {BasePart}, gridParts: {BasePart}, groupsConfig, 
    probs,parentFolder)
    local config = {
        groups = groupsConfig,
        probs  = probs,
    }
    local self = setmetatable(FallingGrid.new(spawnParts, gridParts, config), { __index = FallingObjects })
    self.spawnedModels = {}
    self.parentFolder = parentFolder or workspace
    for groupType in pairs(config.groups) do
        self:setGroupOnFall(groupType, function(activeTiles, spawnLookup)
            self:onGroupFall(groupType, activeTiles, spawnLookup)
        end)
    end
    return self
end

function FallingObjects:onGroupFall(groupType: number, activeTiles: {}, spawnLookup: {})
    local groupConfig = self.groupConfigs[groupType]
    local pool = groupConfig and groupConfig.models
    if not pool or #pool == 0 then
        if self.debugOn then
            warn("FallingObjects: no models defined for group " .. tostring(groupType))
        end
        return
    end
    local fc = groupConfig.fallConfig
    if not fc then
        if self.debugOn then
            warn("FallingObjects: no fallConfig for group " .. tostring(groupType))
        end
        return
    end
    for _, tile in ipairs(activeTiles) do
        local spawnRow  = spawnLookup and spawnLookup[tile.row]
        local spawnPart: BasePart = spawnRow and spawnRow[tile.column]
        if not spawnPart then continue end
        local template: Model = pool[math.random(1, #pool)]
        if not template then continue end
        local model: Model = template:Clone()
        model.Parent = self.parentFolder
        -- fall from spawn point down to the tile part's Y level
        self:animateFall(model, spawnPart.CFrame, tile.part.Position.Y, fc)
        table.insert(self.spawnedModels, model)
    end
end

function FallingObjects:animateFall(model: Model, spawnCFrame: CFrame, targetY: number, fc): {TweenBase}
    local info = TweenInfo.new(fc.duration, fc.style, fc.direction)
    for _, desc in model:GetDescendants() do
        if desc:IsA("BasePart") then
            desc.Anchored = true
        end
    end
    model:PivotTo(spawnCFrame)
    local fallOffset = Vector3.new(0, targetY - spawnCFrame.Position.Y, 0)
    local tweens = {}
    for _, desc in model:GetDescendants() do
        if desc:IsA("BasePart") then
            local tween = TweenService:Create(desc, info, { CFrame = desc.CFrame + fallOffset })
            tween:Play()
            table.insert(tweens, tween)
        end
    end
    return tweens
end

function FallingObjects:start()
    self:triggerGroup(0)
end

function FallingObjects:unload()
    FallingGrid.unload(self)
    for _, model in ipairs(self.spawnedModels) do
        if model and model.Parent then
            model:Destroy()
        end
    end
    self.spawnedModels = {}
end

return FallingObjects