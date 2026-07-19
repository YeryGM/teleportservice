local useStoreSelector = require(script.Parent.useStoreSelector)
local HudSelectors = require(script.Parent.Parent.store.hud.HudSelectors)

local useHud = {}

function useHud.useVisible()
    return useStoreSelector(HudSelectors.selectVisible)
end

function useHud.useLoading()
    return useStoreSelector(HudSelectors.selectLoading)
end

function useHud.useError()
    return useStoreSelector(HudSelectors.selectError)
end

function useHud.useCraftingVisible()
    return useStoreSelector(HudSelectors.selectCrafting)
end

function useHud.useTitle()
    return useStoreSelector(HudSelectors.selectTitle)
end

function useHud.useHint()
    return useStoreSelector(HudSelectors.selectHint)
end

return useHud
