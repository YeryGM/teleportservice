--[[ 
--REMOTE EVENTS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService") 
local itemsRemoteEvents = ReplicatedStorage.events.general.items
local throwBomb:RemoteEvent = itemsRemoteEvents.throwBomb

local playerRemoteEvents = ReplicatedStorage.events.general.player
local hideEvent:RemoteEvent = playerRemoteEvents.hide
local returnToLobbyEvent: RemoteEvent = playerRemoteEvents.returnToLobby
local playAgainEvent: RemoteEvent = playerRemoteEvents.playAgain
local registerWaitingEvent: RemoteEvent = playerRemoteEvents.registerWaiting
local npcAttack: RemoteEvent = playerRemoteEvents.npcAttack
local qteEvent:RemoteEvent = playerRemoteEvents.qte
local spectateTargetEvent: RemoteEvent = playerRemoteEvents.spectateTarget
local spectateStepEvent: RemoteEvent = playerRemoteEvents.spectateStep
local waitingFinishedEvent: RemoteEvent = playerRemoteEvents.waitingFinished
local playerCountUpdateEvent: RemoteEvent = playerRemoteEvents.playerCountUpdate
local toggleShouldCheck: RemoteEvent = playerRemoteEvents.toggleShouldCheck
local staminaModifier: RemoteEvent = playerRemoteEvents.staminaModifier
local ragdoll: RemoteEvent = playerRemoteEvents.ragdoll

local storyRemoteEvents = ReplicatedStorage.events.general.storytelling
local dialogue:RemoteEvent = storyRemoteEvents.dialogue
local handleObjective: RemoteEvent = storyRemoteEvents.HandleObjective
local cutsceneStart: RemoteEvent = storyRemoteEvents.cutsceneStart
local cutsceneStop: RemoteEvent = storyRemoteEvents.cutsceneStop
local cutsceneSkip: RemoteEvent = storyRemoteEvents.cutsceneSkip

local purchasesRemoteEvents = ReplicatedStorage.events.general.purchases
local openShop:RemoteEvent = purchasesRemoteEvents.openShop
-- BINDABLE EVENTS
local playerBindablesEvents = ServerScriptService.events.general.player
local applyEffects: BindableEvent = playerBindablesEvents.applyEffects
local applyEffect: BindableEvent = playerBindablesEvents.applyEffect

local BackpackchangedEvent:BindableEvent = ServerScriptService.events.general.items.backPackChanged 

--REMOTE FUNCTIONS
local itemRemoteFuncs = ReplicatedStorage.funcs.general.items
local getCraftables:RemoteFunction = itemRemoteFuncs.getCraftables
local craft:RemoteFunction = itemRemoteFuncs.craft
local canCraftItem:RemoteFunction = itemRemoteFuncs.canCraftItem
local canCraftItems:RemoteFunction = itemRemoteFuncs.canCraftItems

local playerRemoteFuncs = ReplicatedStorage.funcs.general.player
local requestReviveFunc: RemoteFunction = playerRemoteFuncs.requestRevive
local useStamina: RemoteFunction = playerRemoteFuncs.useStamina
local requestOverview:RemoteFunction = playerRemoteFuncs.requestOverview
local RepeatedPressOk:RemoteFunction = playerRemoteFuncs.RepeatedPressOk
local OrderedPressOk: RemoteFunction = playerRemoteFuncs.OrderedPressOk

local purchasesRemoteFuncs = ReplicatedStorage.funcs.general.purchases
local getItem:RemoteFunction = purchasesRemoteFuncs.getItem
local getItems:RemoteFunction = purchasesRemoteFuncs.getItems
local purchaseItem:RemoteFunction = purchasesRemoteFuncs.purchaseItem
local purchaseItems:RemoteFunction = purchasesRemoteFuncs.purchaseItems


--BINDABLE FUNCTIONS
local playerBindablesFuncs = ServerScriptService.funcs.general.player
local damagePlayer: BindableFunction = playerBindablesFuncs.damagePlayer
local revivePlayer: BindableFunction = playerBindablesFuncs.revivePlayer
local canPlayerRevive: BindableFunction = playerBindablesFuncs.canPlayerRevive
local modifyStamina: BindableFunction = playerBindablesFuncs.modifyStamina 
]]
local Signals = {}
--EVENTS
-----REMOTE EVENTS
Signals[3] = [[ 
local itemsRemoteEvents = ReplicatedStorage.events.general.items
local throwBomb:RemoteEvent = itemsRemoteEvents.throwBomb

local playerRemoteEvents = ReplicatedStorage.events.general.player
local hideEvent:RemoteEvent = playerRemoteEvents.hide
local returnToLobbyEvent: RemoteEvent = playerRemoteEvents.returnToLobby
local playAgainEvent: RemoteEvent = playerRemoteEvents.playAgain
local registerWaitingEvent: RemoteEvent = playerRemoteEvents.registerWaiting
local npcAttack: RemoteEvent = playerRemoteEvents.npcAttack
local qteEvent:RemoteEvent = playerRemoteEvents.qte
local spectateTargetEvent: RemoteEvent = playerRemoteEvents.spectateTarget
local spectateStepEvent: RemoteEvent = playerRemoteEvents.spectateStep
local waitingFinishedEvent: RemoteEvent = playerRemoteEvents.waitingFinished
local playerCountUpdateEvent: RemoteEvent = playerRemoteEvents.playerCountUpdate
local toggleShouldCheck: RemoteEvent = playerRemoteEvents.toggleShouldCheck
local staminaModifier: RemoteEvent = playerRemoteEvents.staminaModifier
local ragdoll: RemoteEvent = playerRemoteEvents.ragdoll

local storyRemoteEvents = ReplicatedStorage.events.general.storytelling
local dialogue:RemoteEvent = storyRemoteEvents.dialogue
local dialogueCue:RemoteEvent = storyRemoteEvents.dialogueCue
local handleObjective: RemoteEvent = storyRemoteEvents.handleObjective
local cutsceneStart: RemoteEvent = storyRemoteEvents.cutsceneStart
local cutsceneStop: RemoteEvent = storyRemoteEvents.cutsceneStop
local cutsceneSkip: RemoteEvent = storyRemoteEvents.cutsceneSkip

local purchasesRemoteEvents = ReplicatedStorage.events.general.purchases
local openShop:RemoteEvent = purchasesRemoteEvents.openShop
]]
-----BINDABLE EVENTS
Signals[1] = [[ 
local playerBindablesEvents = ServerScriptService.events.general.player
local applyEffects: BindableEvent = playerBindablesEvents.applyEffects
local applyEffect: BindableEvent = playerBindablesEvents.applyEffect

local BackpackchangedEvent:BindableEvent = ServerScriptService.events.general.items.backPackChanged 
]]


--FUNCTIONS
-----REMOTE FUNCTIONS
Signals[4] = [[ local itemRemoteFuncs = ReplicatedStorage.funcs.general.items
local getCraftables:RemoteFunction = itemRemoteFuncs.getCraftables
local craft:RemoteFunction = itemRemoteFuncs.craft
local canCraftItem:RemoteFunction = itemRemoteFuncs.canCraftItem
local canCraftItems:RemoteFunction = itemRemoteFuncs.canCraftItems

local playerRemoteFuncs = ReplicatedStorage.funcs.general.player
local requestReviveFunc: RemoteFunction = playerRemoteFuncs.requestRevive
local useStamina: RemoteFunction = playerRemoteFuncs.useStamina
local requestOverview:RemoteFunction = playerRemoteFuncs.requestOverview
local RepeatedPressOk:RemoteFunction = playerRemoteFuncs.RepeatedPressOk
local OrderedPressOk: RemoteFunction = playerRemoteFuncs.OrderedPressOk

local purchasesRemoteFuncs = ReplicatedStorage.funcs.general.purchases
local getItem:RemoteFunction = purchasesRemoteFuncs.getItem
local getItems:RemoteFunction = purchasesRemoteFuncs.getItems
local purchaseItem:RemoteFunction = purchasesRemoteFuncs.purchaseItem
local purchaseItems:RemoteFunction = purchasesRemoteFuncs.purchaseItems 
]]

-----BINDABLE FUNCTIONS
Signals[2] = [[ 
local playerBindablesFuncs = ServerScriptService.funcs.general.player
local damagePlayer: BindableFunction = playerBindablesFuncs.damagePlayer
local revivePlayer: BindableFunction = playerBindablesFuncs.revivePlayer
local canPlayerRevive: BindableFunction = playerBindablesFuncs.canPlayerRevive
local modifyStamina: BindableFunction = playerBindablesFuncs.modifyStamina 
]]


--create(Signals)