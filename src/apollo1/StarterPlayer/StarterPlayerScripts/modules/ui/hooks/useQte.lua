local useStoreSelector = require(script.Parent.useStoreSelector)
local QteSelectors = require(script.Parent.Parent.store.qte.QteSelectors)

local useQte = {}
  
function useQte.useVisible()
    return useStoreSelector(QteSelectors.selectVisible)
end

function useQte.useLoading()
    return useStoreSelector(QteSelectors.selectLoading)
end

function useQte.useError()
    return useStoreSelector(QteSelectors.selectError)
end

function useQte.useActiveQte()
    return useStoreSelector(QteSelectors.selectActiveQte)
end

function useQte.useQteData()
    return useStoreSelector(QteSelectors.selectQteData)
end

function useQte.useQteSelected(qteId)
    local selectedQte = useStoreSelector(QteSelectors.selectActiveQte)
    return selectedQte == qteId
end
return useQte
