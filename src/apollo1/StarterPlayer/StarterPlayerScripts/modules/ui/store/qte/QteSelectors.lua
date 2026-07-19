local UiSelectors = require(script.Parent.Parent.ui.UiSelectors)

local QteSelectors = {}

function QteSelectors.selectVisible(state)
    return UiSelectors.selectQteVisible(state) == true
end

function QteSelectors.selectLoading(state)
    return state.Qte.ui.loading
end

function QteSelectors.selectError(state)
    return state.Qte.ui.error
end

function QteSelectors.selectActiveQte(state)
    return state.Qte.activeQte
end

function QteSelectors.selectQteData(state)
    return state.Qte.qteData
end

return QteSelectors