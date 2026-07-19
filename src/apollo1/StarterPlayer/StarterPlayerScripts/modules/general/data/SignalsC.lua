local DEBUG_MODE = true

--[[ local Player = game:GetService("Players").LocalPlayer
local PlayerScripts = Player.PlayerScripts
--EVENTS BINDABLE
local itemEvents = PlayerScripts.events.general.items
local backPackChangedEvent:BindableEvent = itemEvents.backPackChanged
local playerEvents = PlayerScripts.events.general.player
local changeSpectator: BindableEvent = playerEvents.spectateStep
-- FUNCS BINDABLE
local playerFuncs = PlayerScripts.funcs.general.player
local requestRevive: BindableFunction = playerFuncs.requestRevive ]]


--SHOULD BE STARTER PLAYER AS THIS RUNS VIA COMM AND NOT ON RUNTIME
-- SO CHANGE ALL (P)layerScripts to StarterPlayer.StarterPlayerScripts
local Signals = {
    signals = {},
}

Signals.signals[1] = {
    {folder = "StarterPlayer.StarterPlayerScripts.events.general.items", events = {"backPackChanged"}},
    {folder = "StarterPlayer.StarterPlayerScripts.events.general.player", events = {"spectateStep"}},
}

Signals.signals[2] = {
    {folder = "StarterPlayer.StarterPlayerScripts.funcs.general.player", events = {"requestRevive"}},
}

Signals.signals[3] = {
    {folder = "ReplicatedStorage.events.general.lobby", events = {"OpenLobbyUI", "CloseLobbyUI", "SubmitLobbyConfig", "CancelLobby"}},
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
                    print("[SignalsC] Creado: " .. signal.folder .. "." .. eventName)
                end
            end
        end
    end
end

return Signals