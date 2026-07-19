local RootStore = require(script.Parent.Parent.RootStore)

local CutsceneActions = {}

function CutsceneActions.getState()
    return RootStore.producer.Cutscene:getState()
end

function CutsceneActions.setLoading(value:boolean)
    RootStore.producer.Cutscene.setLoading(value)
end

function CutsceneActions.setError(value:boolean)
    RootStore.producer.Cutscene.setError(value)
end

function CutsceneActions.setBarsActive(value:boolean)
    RootStore.producer.Cutscene.setBarsActive(value)
end

function CutsceneActions.setBarsHeightScale(value:number)
    RootStore.producer.Cutscene.setBarsHeightScale(value)
end

function CutsceneActions.setSkipVotes(votes:number, totalPlayers:number)
    RootStore.producer.Cutscene.setSkipVotes(votes,totalPlayers)
end


return CutsceneActions