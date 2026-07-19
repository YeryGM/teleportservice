local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.packages.Promise)
local Tolls = require(ReplicatedStorage.modules.general.data.Info).Tolls

local PHASE_WAIT_OPPOSITE_TOUCH = "wait_opposite_touch"
local PHASE_WAIT_ORIGIN_END = "wait_origin_end"
local PHASE_WAIT_OPPOSITE_END = "wait_opposite_end"

local ZoneDetector = {
    loaded = false,
    conns = {},
    tollConns = {},
    pendingTransition = nil,
    recentTransition = nil,
    touchDebounce = {},
    localPlayer = nil,
    localCharacter = nil,
    localRootPart = nil,
    inactivityTimeoutSec = 8,
    touchDebounceSec = 0.35,
    transitionDedupeSec = 0.5,
    debugOn = false,
    tags = {
        toll = "zt",
    },
}

local function getTollConfig(tollPart: BasePart)
    local pairId = tollPart:GetAttribute("pairId")
    local first = tollPart:GetAttribute("first")
    if typeof(pairId) ~= "number" then
        return nil
    end
    if typeof(first) ~= "boolean" then
        return nil
    end
    local pairConfig = Tolls[pairId]
    if not pairConfig then
        return nil
    end
    local zones = pairConfig[first]
    if not zones then
        return nil
    end
    if typeof(zones[1]) ~= "string" or typeof(zones[2]) ~= "string" then
        return nil
    end
    return {
        pairId = pairId,
        first = first,
        zones = zones,
    }
end

function ZoneDetector:makeTouchKey(pairId: number, first: boolean)
    return tostring(pairId) .. ":" .. tostring(first)
end

function ZoneDetector:isPendingConfigCompatible(pending, config: {pairId: number, first: boolean, zones: {}})
    if pending.pairId ~= config.pairId then
        return false
    end
    local isOriginSide = pending.first == config.first
    if isOriginSide then
        return pending.zoneA == config.zones[1] and pending.zoneB == config.zones[2]
    end
    return pending.zoneA == config.zones[2] and pending.zoneB == config.zones[1]
end

function ZoneDetector:isAnyTollTouching(pending)
    return pending.originTouching or pending.oppositeTouching
end

function ZoneDetector:createPendingRecord(config: {pairId: number, first: boolean, zones: {}})
    local now = os.clock()
    return {
        pairId = config.pairId,
        first = config.first,
        zoneA = config.zones[1],
        zoneB = config.zones[2],
        phase = PHASE_WAIT_OPPOSITE_TOUCH,
        originTouching = true,
        oppositeTouching = false,
        epoch = 1,
        startedAt = now,
        lastContactAt = now,
        promise = nil,
    }
end

function ZoneDetector:clearPendingTransition()
    local pending = self.pendingTransition
    if not pending then
        return
    end
    if pending.promise then
        pending.promise:cancel()
    end
    self.pendingTransition = nil
end

function ZoneDetector:refreshPendingInactivity(pending)
    if pending.promise then
        pending.promise:cancel()
        pending.promise = nil
    end

    local cancelled = false
    local delayedThread = nil
    local promise = Promise.new(function(_resolve, reject, onCancel)
        delayedThread = task.delay(self.inactivityTimeoutSec, function()
            if cancelled then
                return
            end
            reject("inactive")
        end)
        onCancel(function()
            cancelled = true
            if delayedThread then
                task.cancel(delayedThread)
            end
        end)
    end)

    pending.promise = promise
    promise:catch(function(_err)
        if self.pendingTransition ~= pending then
            return
        end
        local inactiveFor = os.clock() - pending.lastContactAt
        if self:isAnyTollTouching(pending) or inactiveFor < self.inactivityTimeoutSec then
            self:refreshPendingInactivity(pending)
            return
        end
        self.pendingTransition = nil
        if self.debugOn then
            print("Pending transition expired due inactivity for pair", pending.pairId)
        end
    end)
end

function ZoneDetector:clearRecentTransition()
    self.recentTransition = nil
end

function ZoneDetector:markTransition(previousZone: number, newZone: number)
    self.recentTransition = {
        previousZone = previousZone,
        newZone = newZone,
        at = os.clock(),
    }
end

function ZoneDetector:isDuplicateTransition(previousZone: number, newZone: number)
    local recent = self.recentTransition
    if not recent then
        return false
    end
    if recent.previousZone ~= previousZone or recent.newZone ~= newZone then
        return false
    end
    return os.clock() - recent.at < self.transitionDedupeSec
end

function ZoneDetector:refreshLocalCharacter(character: Model?)
    self.localCharacter = character
    if not character then
        self.localRootPart = nil
        return
    end
    self.localRootPart = character:FindFirstChild("HumanoidRootPart")
end

function ZoneDetector:isLocalRootPartHit(hit: BasePart)
    local character = self.localCharacter
    if not character then
        return false
    end
    local rootPart = self.localRootPart
    if not rootPart or rootPart.Parent ~= character then
        rootPart = character:FindFirstChild("HumanoidRootPart")
        self.localRootPart = rootPart
    end
    if hit ~= rootPart then
        return false
    end
    local humanoid = character:FindFirstChild("Humanoid")
    return humanoid ~= nil
end

function ZoneDetector:createPair(tollPart: BasePart)--[part that has two tolls inside]
    if not tollPart:IsA("BasePart") then
        if self.debugOn then
            print("Attempted to create toll on non-BasePart:", tollPart:GetFullName())
        end
        return
    end
    local pair = tollPart:GetChildren()
    if #pair ~= 2 then
        if self.debugOn then
            print("Toll part does not have exactly 2 children:", tollPart:GetFullName())
        end
        return
     end
    for _, child in ipairs(pair) do
        if not child:IsA("BasePart") then
            if self.debugOn then
                print("Toll part has non-BasePart child:", child:GetFullName())
            end
            return
        else
            self:createToll(child)
        end
    end
end

function ZoneDetector:createToll(tollPart: BasePart)
    local config = getTollConfig(tollPart)
    if not config then
        if self.debugOn then
            print("Invalid toll configuration for part:", tollPart:GetFullName())
        end
        return
    end
    if not self.tollConns[tollPart] then
        self.tollConns[tollPart] = {}
    end
    local conn = tollPart.Touched:Connect(function(hit)
        self:onTollTouched(hit, config)
    end)
    table.insert(self.tollConns[tollPart], conn)
    local conn2 = tollPart.TouchEnded:Connect(function(hit)
        self:onTollTouchEnded(hit, config)
    end)
    table.insert(self.tollConns[tollPart], conn2)
end

function ZoneDetector:onTollTouched(hit: BasePart, config: {pairId: number, first: boolean, zones: {}})
    if not self:isLocalRootPartHit(hit) then
        return
    end
    if self:isTouchDebounced(config.pairId, config.first) then
        return
    end
    self:startPendingTransition(config)
end

function ZoneDetector:onTollTouchEnded(hit: BasePart, config:{pairId:number, first:boolean, zones:{}})
    if not self:isLocalRootPartHit(hit) then
        return
    end
    self:confirmPendingTransition(config)
end

function ZoneDetector:isTouchDebounced(pairId: number, first: boolean)
    local key = self:makeTouchKey(pairId, first)
    local now = os.clock()
    local lastTouch = self.touchDebounce[key]
    if lastTouch and now - lastTouch < self.touchDebounceSec then
        return true
    end
    self.touchDebounce[key] = now
    return false
end

function ZoneDetector:clearTouchDebounce()
    self.touchDebounce = {}
end

function ZoneDetector:startPendingTransition(config: {pairId: number, first: boolean, zones: {}})
    local pending = self.pendingTransition
    if not pending then
        pending = self:createPendingRecord(config)
        self.pendingTransition = pending
        if self.debugOn then
            print("Started pending transition for pair", config.pairId)
        end
        self:refreshPendingInactivity(pending)
        return
    end

    if not self:isPendingConfigCompatible(pending, config) then
        self:clearPendingTransition()
        pending = self:createPendingRecord(config)
        self.pendingTransition = pending
        if self.debugOn then
            print("Replaced pending transition for pair", config.pairId)
        end
        self:refreshPendingInactivity(pending)
        return
    end

    pending.lastContactAt = os.clock()
    local isOriginSide = pending.first == config.first
    if isOriginSide then
        pending.originTouching = true
        if pending.phase == PHASE_WAIT_OPPOSITE_END then
            pending.phase = PHASE_WAIT_OPPOSITE_TOUCH
            pending.oppositeTouching = false
            pending.epoch = pending.epoch + 1
            if self.debugOn then
                print("Origin retouched; retry required for pair", config.pairId)
            end
        end
    else
        pending.oppositeTouching = true
        if pending.phase == PHASE_WAIT_OPPOSITE_TOUCH then
            pending.phase = PHASE_WAIT_ORIGIN_END
            if self.debugOn then
                print("Opposite toll touched for pair", config.pairId)
            end
        end
    end

    self:refreshPendingInactivity(pending)
end

function ZoneDetector:confirmPendingTransition(config: {pairId: number, first: boolean, zones: {}})
    local pending = self.pendingTransition
    if not pending then
        return
    end
    if not self:isPendingConfigCompatible(pending, config) then
        return
    end

    pending.lastContactAt = os.clock()
    local isOriginSide = pending.first == config.first
    if isOriginSide then
        pending.originTouching = false
        if pending.phase == PHASE_WAIT_OPPOSITE_TOUCH then
            if self.debugOn then
                print("Origin ended before opposite touch; canceling for pair", config.pairId)
            end
            self:clearPendingTransition()
            return
        end
        if pending.phase == PHASE_WAIT_ORIGIN_END then
            pending.phase = PHASE_WAIT_OPPOSITE_END
            if self.debugOn then
                print("Origin ended; waiting for opposite end for pair", config.pairId)
            end
        end
        self:refreshPendingInactivity(pending)
        return
    end

    pending.oppositeTouching = false
    if pending.phase == PHASE_WAIT_ORIGIN_END then
        pending.phase = PHASE_WAIT_OPPOSITE_TOUCH
        if self.debugOn then
            print("Opposite ended too early; waiting for opposite touch retry for pair", config.pairId)
        end
        self:refreshPendingInactivity(pending)
        return
    end
    if pending.phase ~= PHASE_WAIT_OPPOSITE_END then
        self:refreshPendingInactivity(pending)
        return
    end
    if pending.originTouching then
        pending.phase = PHASE_WAIT_OPPOSITE_TOUCH
        pending.epoch = pending.epoch + 1
        if self.debugOn then
            print("Origin still touching at opposite end; retry required for pair", config.pairId)
        end
        self:refreshPendingInactivity(pending)
        return
    end

    local previousZone, newZone = pending.zoneA, pending.zoneB
    self:clearPendingTransition()
    self:transitionPlayer(previousZone, newZone)
end

function ZoneDetector:transitionPlayer(previousZone: number?, newZone: number)
    if not previousZone or not newZone then
        if self.debugOn then
            print("Previous zone or new zone is nil. Previous zone:", previousZone, "New zone:", newZone)
        end
        return
    end
    local localPlayer = self.localPlayer
    if not localPlayer then
        if self.debugOn then
            print("Local player is nil when trying to transition zones. Previous zone:", previousZone, "New zone:", newZone)
        end
        return
    end
    if previousZone == newZone then
        if self.debugOn then
            print("Skipping transition with identical zones", previousZone)
        end
        return
    end
    if self:isDuplicateTransition(previousZone, newZone) then
        if self.debugOn then
            print("Skipped duplicate transition", previousZone, newZone)
        end
        return
    end
    if self.loadZone then
        self:markTransition(previousZone, newZone)
        self.loadZone(previousZone, newZone)
        if self.debugOn then
            print("Transitioned from", previousZone, "to", newZone)
        end
    else
        if self.debugOn then
            print("No loadZone callback set. Cannot transition from", previousZone, "to", newZone)
        end
    end
end

function ZoneDetector:SetCallback(callback)
    self.loadZone = callback
end

function ZoneDetector:load()
    if self.loaded then
        return
    end
    self.loaded = true

    self.localPlayer = Players.LocalPlayer
    if self.localPlayer then
        self:refreshLocalCharacter(self.localPlayer.Character)
        table.insert(self.conns, self.localPlayer.CharacterAdded:Connect(function(character)
            self:refreshLocalCharacter(character)
            self:clearPendingTransition()
            self:clearTouchDebounce()
        end))
        table.insert(self.conns, self.localPlayer.CharacterRemoving:Connect(function()
            self:refreshLocalCharacter(nil)
            self:clearPendingTransition()
            self:clearTouchDebounce()
        end))
    end

    for _num, toll in ipairs(CollectionService:GetTagged(ZoneDetector.tags.toll)) do
        self:createPair(toll)
    end
end

function ZoneDetector:unload()
    self.loaded = false
    self:clearPendingTransition()
    self:clearRecentTransition()
    self:clearTouchDebounce()
    self:refreshLocalCharacter(nil)

    for tollPart, tollConnections in pairs(self.tollConns) do
        for _, tollConn in ipairs(tollConnections) do
            tollConn:Disconnect()
        end
        self.tollConns[tollPart] = nil
    end

    for _, conn in ipairs(self.conns) do
        conn:Disconnect()
    end
    self.conns = {}
end
return ZoneDetector