local effects = require(script.Parent.Parent.Parent.data.info.IFSEffects)

local Effects = {}
Effects.__index = Effects

function Effects.new(player: Player)
    local self = setmetatable({}, Effects)
    self.player = player
    self.activeEffects = {}
    return self
end

function Effects:unloadCharacter()
    if next(self.activeEffects) then
        for _effectId, module in pairs(self.activeEffects) do
            if module and module.unload then
                module:unload()
            end
        end
    end
    table.clear(self.activeEffects)
end

function Effects:effectExists(effectId:number): boolean
    return effects[effectId] ~= nil
end

function Effects:getActiveEffects()
    return self.activeEffects
end

function Effects:applyEffect(effectId:number, metadata)
    if not self:effectExists(effectId) then
        return
    end
    local existingModule = self.activeEffects[effectId]
    if existingModule then
        existingModule:load(metadata)
        return
    end
    local effectModule = effects[effectId]
    if not effectModule then
        return
    end
    local module = effectModule.new(self.player, function()
        self:removeEffect(effectId)
    end)
    if module then
        self.activeEffects[effectId] = module
        module:load(metadata)
    end
end

function Effects:removeEffect(effectId:number)
    if self.activeEffects[effectId] then
        self.activeEffects[effectId] = nil
    end
end

function Effects:removeAllEffects()
    for effectId, _ in pairs(self.activeEffects) do
        local effectModule = effects[effectId]
        if effectModule and effectModule.forceRemove then
            effectModule.forceRemove()
        end
    end
    self.activeEffects = {}
end

return Effects