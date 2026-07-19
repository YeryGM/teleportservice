local RootStore = require(script.Parent.Parent.RootStore)


local QteActions = {}

function QteActions.getState()
    return RootStore.producer.Qte:getState()
end

function QteActions.setLoading(value:boolean)
    RootStore.producer.Qte.setLoading(value)
end

function QteActions.setError(value:boolean)
    RootStore.producer.Qte.setError(value)
end

function QteActions.setActive(qteId:number?)
    RootStore.producer.Qte.setActive(qteId)
end

function QteActions.setQteData(data)
    RootStore.producer.Qte.setQteData(data)
end

return QteActions