local QteActions = require(script.Parent.Parent.store.qte.QteActions)

local UISQte = {}
local validator = nil

function UISQte.setQte(qteEnum: number?)
    QteActions.setActive(qteEnum)
end

function UISQte.setValidator(nextValidator)
    validator = nextValidator
end

function UISQte.validate(keycode): boolean
    if not validator then
        return false
    end
    return validator(keycode)
end

function UISQte.setQteData(data)
    QteActions.setQteData(data)
end

return UISQte
