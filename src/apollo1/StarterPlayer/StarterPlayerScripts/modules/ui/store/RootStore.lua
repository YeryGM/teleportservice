local RootProducer = require(script.Parent.RootProducer)

local RootStore = {}

function RootStore.getState()
    return RootProducer:getState()
end

function RootStore.subscribe(listener)
    return RootProducer:subscribe(listener)
end

RootStore.producer = RootProducer

return RootStore