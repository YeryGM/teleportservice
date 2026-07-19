local RootStore = require(script.Parent.Parent.RootStore)

local MinigameActions = {}

function MinigameActions.getState()
    return RootStore.producer.Minigame:getState()
end

function MinigameActions.setLoading(value:boolean)
    RootStore.producer.Minigame.setLoading(value)
end

function MinigameActions.setError(value:boolean)
    RootStore.producer.Minigame.setError(value)
end

return MinigameActions