local RootStore = require(script.Parent.Parent.RootStore)

local HudActions = {}

function HudActions.getState()
    return RootStore.producer.Hud:getState()
end

function HudActions.setLoading(value:boolean)
    RootStore.producer.Hud.setLoading(value)
end

function HudActions.setError(value:boolean)
    RootStore.producer.Hud.setError(value)
end

function HudActions.setCrafting(value:boolean)
    RootStore.producer.Hud.setCrafting(value)
end

function HudActions.setHudTitle(title:string)
    RootStore.producer.Hud.setHudTitle(title)
end

function HudActions.setHudHint(hint:string)
    RootStore.producer.Hud.setHudHint(hint)
end

return HudActions