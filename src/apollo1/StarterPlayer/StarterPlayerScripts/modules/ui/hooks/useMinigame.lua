local minigameSelectors = require(script.Parent.Parent.store.minigame.MinigameSelectors)
local useStoreSelector = require(script.Parent.useStoreSelector)

local useMinigame = {}

function useMinigame.useVisible()
    return useStoreSelector(minigameSelectors.selectVisible)
end

return useMinigame
