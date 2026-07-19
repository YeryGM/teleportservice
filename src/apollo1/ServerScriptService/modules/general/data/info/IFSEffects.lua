local effectsFolder = script.Parent.Parent.Parent.items.effects
local EffectList = {
    [100] = require(effectsFolder.RandomEffect),
    [101] = require(effectsFolder.HealthEffect),
    [102] = require(effectsFolder.JumpEffect),
    [103] = require(effectsFolder.SpeedEffect),
    [104] = require(effectsFolder.StaminaEffect),
    [150] = require(effectsFolder.PoisonEffect),
    [151] = require(effectsFolder.DeathEffect),
    [152] = require(effectsFolder.FreezeEffect),
    [153] = require(effectsFolder.SlowEffect),
}
return EffectList