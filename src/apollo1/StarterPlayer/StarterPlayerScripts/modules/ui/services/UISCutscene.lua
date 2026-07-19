local UIActions = require(script.Parent.Parent.store.ui.UiActions)
local CutsceneActions = require(script.Parent.Parent.store.cutscene.CutsceneActions)

local UISCutscene = {}

function UISCutscene.initCutscene(barsOn: boolean, barsHeightScale: number)
    UIActions.setCutscene()
    if not barsOn then
        return
    end
    barsHeightScale = math.clamp(barsHeightScale, 0, 0.5)
    CutsceneActions.setBarsActive(barsOn)
    CutsceneActions.setBarsHeightScale(barsHeightScale)
end

function UISCutscene.endCutscene()
    UIActions.setGameplay()
    CutsceneActions.setBarsActive(false)
    CutsceneActions.setBarsHeightScale(0)
end

return UISCutscene
