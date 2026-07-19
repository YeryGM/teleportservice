local StaminaActions = require(script.Parent.Parent.store.stamina.StaminaActions)

local StaminaService = {}

function StaminaService.updateStamina(newStamina: number)
    StaminaActions.setCurrent(newStamina)
end

function StaminaService.updateMaxStamina(newMaxStamina: number)
    StaminaActions.setMax(newMaxStamina)
end

return StaminaService
