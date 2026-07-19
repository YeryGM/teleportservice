--[[ local Player = game:GetService("Players").LocalPlayer
local PlayerScripts = Player.PlayerScripts
--EVENTS BINDABLE
local itemEvents = PlayerScripts.events.general.items
local backPackChangedEvent:BindableEvent = itemEvents.backPackChanged
local playerEvents = PlayerScripts.events.general.player
local changeSpectator: BindableEvent = playerEvents.spectateStep
-- FUNCS BINDABLE
local playerFuncs = PlayerScripts.funcs.general.player
local requestRevive: BindableFunction = playerFuncs.requestRevive
 ]]


--SHOULD BE STARTER PLAYER AS THIS RUNS VIA COMM AND NOT ON RUNTIME
-- SO CHANGE ALL (P)layerScripts to StarterPlayer.StarterPlayerScripts
local Signals = {}
--EVENTS BINDABLE
Signals[1] = [[
local itemEvents = StarterPlayer.StarterPlayerScripts.events.general.items
local backPackChangedEvent:BindableEvent = itemEvents.backPackChanged
local playerEvents = StarterPlayer.StarterPlayerScripts.events.general.player
local changeSpectator: BindableEvent = playerEvents.spectateStep
]]
-- FUNCS BINDABLE
Signals[2] = [[
local playerFuncs = StarterPlayer.StarterPlayerScripts.funcs.general.player
local requestRevive: BindableFunction = playerFuncs.requestRevive
]]

--create(Signals)