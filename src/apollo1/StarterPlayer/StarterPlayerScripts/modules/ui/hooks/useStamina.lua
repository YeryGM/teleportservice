local StaminaSelectors = require(script.Parent.Parent.store.stamina.StaminaSelectors)

local useStoreSelector = require(script.Parent.useStoreSelector)

local useStamina = {}

function useStamina.useVisible()
    return useStoreSelector(StaminaSelectors.selectVisible)
end

function useStamina.usePercent()
    return useStoreSelector(StaminaSelectors.selectPercent)
end

function useStamina.useCurrent()
    return useStoreSelector(StaminaSelectors.selectCurrent)
end

function useStamina.useMax()
    return useStoreSelector(StaminaSelectors.selectMax)
end

function useStamina.useShownAtFull()
    return useStoreSelector(StaminaSelectors.selectShownAtFull)
end

function useStamina.useIsFull()
    return useStoreSelector(StaminaSelectors.selectIsFull)
end

function useStamina.useIsInfinite()
    return useStoreSelector(StaminaSelectors.selectIsInfinite)
end

return useStamina
