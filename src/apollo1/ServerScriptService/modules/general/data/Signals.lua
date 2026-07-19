local DEBUG_MODE = true

--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local ServerScriptService = game:GetService("ServerScriptService")
local Signals = {
    signals = {},
}
--EVENTS
-----REMOTE
--[[ local itemsRemoteEvents = ReplicatedStorage.events.general.items
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
 ]]

Signals.signals[3] = {
    {folder = "ReplicatedStorage.events.general.items", events = {"throwBomb"}},
    {folder = "ReplicatedStorage.events.general.player", events = {"hide", "returnToLobby", "playAgain", "registerWaiting",
     "npcAttack", "qte", "spectateTarget", "spectateStep", "waitingFinished", "playerCountUpdate", "toggleShouldCheck",
      "staminaModifier", "ragdoll"}},
    {folder = "ReplicatedStorage.events.general.storytelling", events = {"dialogue", "handleObjective", "start", "stop", "skip"}},
    {folder = "ReplicatedStorage.events.general.purchases", events = {"openShop"}},
    {folder = "ReplicatedStorage.events.general.lobby", events = {"OpenLobbyUI", "CloseLobbyUI", "SubmitLobbyConfig", "CancelLobby"}}
}

----BINDABLE
--[[ local playerBindablesEvents = ServerScriptService.events.general.player
local applyEffects: BindableEvent = playerBindablesEvents.applyEffects
local applyEffect: BindableEvent = playerBindablesEvents.applyEffect

local BackpackchangedEvent:BindableEvent = ServerScriptService.events.general.items.backPackChanged 
]]

Signals.signals[1] = {
    {folder = "ServerScriptService.events.general.player", events = {"applyEffects", "applyEffect"}},
    {folder = "ServerScriptService.events.general.items", events = {"backPackChanged"}}
}

--FUNCTIONS
-----REMOTE
--[[ local itemRemoteFuncs = ReplicatedStorage.funcs.general.items
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

Signals.signals[4] = {
    {folder = "ReplicatedStorage.funcs.general.items", events = {"getCraftables", "craft", "canCraftItem", "canCraftItems"}},
    {folder = "ReplicatedStorage.funcs.general.player", events = {"requestRevive", "useStamina", "requestOverview", "RepeatedPressOk", "OrderedPressOk"}},
    {folder = "ReplicatedStorage.funcs.general.purchases", events = {"getItem", "getItems", "purchaseItem", "purchaseItems"}}
}

-----BINDABLE
--[[ local playerBindablesFuncs = ServerScriptService.funcs.general.player
local damagePlayer: BindableFunction = playerBindablesFuncs.damagePlayer
local revivePlayer: BindableFunction = playerBindablesFuncs.revivePlayer
local canPlayerRevive: BindableFunction = playerBindablesFuncs.canPlayerRevive
local modifyStamina: BindableFunction = playerBindablesFuncs.modifyStamina 
]]

Signals.signals[2] = {
    {folder = "ServerScriptService.funcs.general.player", events = {"damagePlayer", "revivePlayer", "canPlayerRevive", "modifyStamina"}}
}


local function createSignal(name: string, parent: Instance, type: number)
    if parent:FindFirstChild(name) then
        return
    end
    local typeMap = {
        [1] = "BindableEvent",
        [2] = "BindableFunction",
        [3] = "RemoteEvent",
        [4] = "RemoteFunction"
    }
    if not typeMap[type] then
        return
    end
    local event = Instance.new(typeMap[type])
    event.Name = name
    event.Parent = parent
    return event
end

local function createFolder(path:string)
    -- Split the path into folder names
    local folderNames = {}
    for folderName in path:gmatch("[^%.]+") do
        table.insert(folderNames, folderName)
    end
    local currentParent = game
    for _, folderName in ipairs(folderNames) do
        local folder = currentParent:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = folderName
            folder.Parent = currentParent
        end
        currentParent = folder
    end
    return currentParent
end

function Signals.create()
    for type, signals in ipairs(Signals.signals) do
        for _, signal in ipairs(signals) do
            local folder = createFolder(signal.folder)
            for _, eventName in ipairs(signal.events) do
                createSignal(eventName, folder, type)
                if DEBUG_MODE then
                    print("[Signals] Creado: " .. signal.folder .. "." .. eventName)
                end
            end
        end
    end
end

return Signals

