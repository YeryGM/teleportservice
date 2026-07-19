local deathSelectors = require(script.Parent.Parent.store.death.DeathSelectors)
local useStoreSelector = require(script.Parent.useStoreSelector)

local useDeath = {}

function useDeath.useOverviewData()
    return useStoreSelector(deathSelectors.selectOverviewData)
end

function useDeath.useOverviewOpen()
    return useStoreSelector(deathSelectors.selectOverviewOpen)
end

function useDeath.useSpectator()
    return useStoreSelector(deathSelectors.selectSpectator)
end

function useDeath.useVisible()
    return useStoreSelector(deathSelectors.selectVisible)
end

function useDeath.useIsSpectating()
    return useStoreSelector(deathSelectors.selectIsSpectating)
end

return useDeath
