local RootStore = require(script.Parent.Parent.RootStore)

local DeathActions = {}

function DeathActions.getState()
    return RootStore.producer.death:getState()
end

function DeathActions.setLoading(value:boolean)
    RootStore.producer.death.setLoading(value)
end

function DeathActions.setError(value)
    RootStore.producer.death.setError(value)
end

function DeathActions.setCountdownData(countDownData)
    RootStore.producer.death.setCountdownData(countDownData)
end

function DeathActions.setWaitingCounts(counts)
    RootStore.producer.death.setWaitingCounts(counts)
end

function DeathActions.setOverviewData(overviewData)
    RootStore.producer.death.setOverviewData(overviewData)
end

function DeathActions.setSpectator(targetName:string)
    RootStore.producer.death.setSpectator(targetName)
end

function DeathActions.setOverviewOpen(overviewOpen:boolean)
    RootStore.producer.death.setOverviewOpen(overviewOpen)
end

return DeathActions