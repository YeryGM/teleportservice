local debugOn = true

local Signals = {
    signals = {},
}

-- REMOTE EVENTS (lobby only)
Signals.signals[3] = {
    {folder = "ReplicatedStorage.events.general.lobby", events = {"OpenLobbyUI", "CloseLobbyUI", "SubmitLobbyConfig", "CancelLobby"}},
}

-- BINDABLE EVENTS (none for lobby)
Signals.signals[1] = {}

-- BINDABLE FUNCTIONS (none for lobby)
Signals.signals[2] = {}

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
                if debugOn then
                    print("[SignalsC] Creado: " .. signal.folder .. "." .. eventName)
                end
            end
        end
    end
end

return Signals
