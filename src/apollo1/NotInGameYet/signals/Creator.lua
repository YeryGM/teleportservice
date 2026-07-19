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

local function parseDeclarations(text)
    local aliases = {}
    local parsed = {}

    for line in text:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$")
        if line == "" then
            continue
        end

        -- Folder alias
        local alias, path =
            line:match("^local%s+(%w+)%s*=%s*([%w%.]+)$")

        if alias then
            aliases[alias] = path
            continue
        end

        -- Alias.signal
        local _, _, folderAlias, signal = line:match("^local%s+(%w+)%s*:%s*(%w+)%s*=%s*(%w+)%.(%w+)$")

        if folderAlias then
            parsed[#parsed + 1] = {
                folder = aliases[folderAlias],
                signal = signal,
            }
            continue
        end

        -- Full path
        local _, _, fullPath =
            line:match("^local%s+(%w+)%s*:%s*(%w+)%s*=%s*([%w%.]+)$")

        if fullPath then
            local folder, signalFull = fullPath:match("(.+)%.([^.]+)$")

            if folder and signalFull then
                parsed[#parsed + 1] = {
                    folder = folder,
                    signal = signalFull,
                }
            end
        end
    end

    return parsed
end

local function create(signals)
    for signalType, declarationText in pairs(signals) do
        local parsed = parseDeclarations(declarationText)

        for _, info in ipairs(parsed) do
            local folder = createFolder(info.folder)
            createSignal(info.signal, folder, signalType)
        end
    end
end
