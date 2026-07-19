local RootStore = require(script.Parent.Parent.RootStore)

local StaminaActions = {}

function StaminaActions.getState()
    return RootStore.producer.stamina:getState()
end

function StaminaActions.setLoading(value:boolean)
    RootStore.producer.stamina.setLoading(value)
end

function StaminaActions.setError(value)
    RootStore.producer.stamina.setError(value)
end

function StaminaActions.setMax(max:number)
    RootStore.producer.stamina.setMax(max)
end

function StaminaActions.setCurrent(current:number)
    RootStore.producer.stamina.setCurrent(current)
end

function StaminaActions.setShownAtFull(shownAtFull:boolean)
    RootStore.producer.stamina.setShownAtFull(shownAtFull)
end

return StaminaActions