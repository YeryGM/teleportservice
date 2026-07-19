local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Reflex = require(ReplicatedStorage.packages.Reflex)

local UIProducer       = require(script.Parent.ui.UIProducer)   
local ShopProducer     = require(script.Parent.shop.ShopProducer)
local CraftingProducer = require(script.Parent.crafting.CraftingProducer)
local DeathProducer    = require(script.Parent.death.DeathProducer)
local ObjectivesProducer = require(script.Parent.objectives.ObjectivesProducer)
local staminaProducer = require(script.Parent.stamina.StaminaProducer)
local SubtitlesProducer = require(script.Parent.subtitles.SubtitlesProducer)
local QteProducer = require(script.Parent.qte.QteProducer)
local HudProducer = require(script.Parent.hud.HudProducer)
local CutsceneProducer = require(script.Parent.cutscene.CutsceneProducer)
local MinigameProducer = require(script.Parent.minigame.MinigameProducer)
local LobbyProducer = require(script.Parent.lobby.LobbyProducer)

local RootProducer = Reflex.combineProducers({
    ui        = UIProducer,
    shop     = ShopProducer,
    crafting = CraftingProducer,
    death    = DeathProducer,
    objectives = ObjectivesProducer,
    stamina = staminaProducer,
    subtitles = SubtitlesProducer,
    qte = QteProducer,
    hud = HudProducer,
    cutscene = CutsceneProducer,
    minigame = MinigameProducer,
    lobby = LobbyProducer,
})

RootProducer.ui = UIProducer
RootProducer.shop = ShopProducer
RootProducer.crafting = CraftingProducer
RootProducer.death = DeathProducer
RootProducer.objectives = ObjectivesProducer
RootProducer.stamina = staminaProducer
RootProducer.subtitles = SubtitlesProducer
RootProducer.qte = QteProducer
RootProducer.Qte = QteProducer
RootProducer.hud = HudProducer
RootProducer.Hud = HudProducer
RootProducer.cutscene = CutsceneProducer
RootProducer.Cutscene = CutsceneProducer
RootProducer.minigame = MinigameProducer
RootProducer.Minigame = MinigameProducer

return RootProducer