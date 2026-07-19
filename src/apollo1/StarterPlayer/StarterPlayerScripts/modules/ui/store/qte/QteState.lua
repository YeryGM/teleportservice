local Qte = {}

function Qte.createInitialState()
    return {
        ui = {
            loading = false,
            error = nil,
        },

        activeQte = nil, -- number | nil
        qteData = nil, -- table | nil
    }
end

return Qte