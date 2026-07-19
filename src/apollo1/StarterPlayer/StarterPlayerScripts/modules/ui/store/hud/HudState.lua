local Hud = {}

function Hud.createInitialState()
    return {
        ui = {
            loading = false,
            error = nil,
            crafting = false,
        },

        title = nil, -- string | nil
        hint = nil, -- string | nil
    }
end

return Hud