local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.packages.Promise)
local Tolls = require(ReplicatedStorage.modules.general.data.Info).Tolls

local PHASE_WAIT_OPPOSITE_TOUCH = "wait_opposite_touch"
local PHASE_WAIT_ORIGIN_END = "wait_origin_end"
local PHASE_WAIT_OPPOSITE_END = "wait_opposite_end"

local ZoneDetector = {
    conns = {},
    tollConns = {},
    pendingTransitions = {},
    recentTransitions = {},
    touchDebounce = {},
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


function ZoneDetector:makePendingKey(player: Player)
    return tostring(player.UserId)
end

function ZoneDetector:makeTouchKey(player: Player, pairId: number, first: boolean)
    return tostring(player.UserId) .. ":" .. tostring(pairId) .. ":" .. tostring(first)
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

function ZoneDetector:clearPendingByKey(key: string)
    local pending = self.pendingTransitions[key]
    if not pending then
        return
    end
    if pending.promise then
        pending.promise:cancel()
    end
    self.pendingTransitions[key] = nil
end

function ZoneDetector:refreshPendingInactivity(player: Player, pending)
    local key = self:makePendingKey(player)
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
        local activePending = self.pendingTransitions[key]
        if activePending ~= pending then
            return
        end
        local inactiveFor = os.clock() - pending.lastContactAt
        if self:isAnyTollTouching(pending) or inactiveFor < self.inactivityTimeoutSec then
            self:refreshPendingInactivity(player, pending)
            return
        end
        self.pendingTransitions[key] = nil
        if self.debugOn then
            print("Pending transition expired due inactivity for", player.Name, "pair", pending.pairId)
        end
    end)
end

function ZoneDetector:clearRecentTransitionForPlayer(player: Player)
    local key = self:makePendingKey(player)
    self.recentTransitions[key] = nil
end

function ZoneDetector:markTransition(player: Player, previousZone: number, newZone: number)
    local key = self:makePendingKey(player)
    self.recentTransitions[key] = {
        previousZone = previousZone,
        newZone = newZone,
        at = os.clock(),
    }
end

function ZoneDetector:isDuplicateTransition(player: Player, previousZone: number, newZone: number)
    local key = self:makePendingKey(player)
    local recent = self.recentTransitions[key]
    if not recent then
        return false
    end
    if recent.previousZone ~= previousZone or recent.newZone ~= newZone then
        return false
    end
    return os.clock() - recent.at < self.transitionDedupeSec
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
            ZoneDetector:createToll(child)
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

function ZoneDetector:getPlayerFromHit(hit: BasePart)
    local character = hit.Parent
    if not character then
        return nil
    end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return nil
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if hit ~= rootPart then
        return nil
    end
    if character and character:FindFirstChild("Humanoid") then
        return Players:GetPlayerFromCharacter(character)
    end
    return nil
end

function ZoneDetector:onTollTouched(hit: BasePart, config: {pairId: number, first: boolean, zones: {}})
    local player = self:getPlayerFromHit(hit)
    if not player then
        return
    end
    if self:isTouchDebounced(player, config.pairId, config.first) then
        return
    end
    self:startPendingTransition(player, config)
end

function ZoneDetector:onTollTouchEnded(hit: BasePart, config:{pairId:number, first:boolean, zones:{}})
    local player = self:getPlayerFromHit(hit)
    if not player then
        return
    end
    self:confirmPendingTransition(player, config)
end

function ZoneDetector:isTouchDebounced(player: Player, pairId: number, first: boolean)
    local key = self:makeTouchKey(player, pairId, first)
    local now = os.clock()
    local lastTouch = self.touchDebounce[key]
    if lastTouch and now - lastTouch < self.touchDebounceSec then
        return true
    end
    self.touchDebounce[key] = now
    return false
end

function ZoneDetector:clearPendingForPlayer(player: Player)
    local key = self:makePendingKey(player)
    self:clearPendingByKey(key)
end

function ZoneDetector:clearTouchDebounceForPlayer(player: Player)
    local prefix = tostring(player.UserId) .. ":"
    for key, _value in pairs(self.touchDebounce) do
        if string.sub(key, 1, #prefix) == prefix then
            self.touchDebounce[key] = nil
        end
    end
end

function ZoneDetector:startPendingTransition(player: Player, config: {pairId: number, first: boolean, zones: {}})
    local key = self:makePendingKey(player)
    local pending = self.pendingTransitions[key]
    if not pending then
        pending = self:createPendingRecord(config)
        self.pendingTransitions[key] = pending
        if self.debugOn then
            print("Started pending transition for", player.Name, "pair", config.pairId)
        end
        self:refreshPendingInactivity(player, pending)
        return
    end

    if not self:isPendingConfigCompatible(pending, config) then
        self:clearPendingByKey(key)
        pending = self:createPendingRecord(config)
        self.pendingTransitions[key] = pending
        if self.debugOn then
            print("Replaced pending transition for", player.Name, "pair", config.pairId)
        end
        self:refreshPendingInactivity(player, pending)
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
                print("Origin retouched; retry required for", player.Name, "pair", config.pairId)
            end
        end
    else
        pending.oppositeTouching = true
        if pending.phase == PHASE_WAIT_OPPOSITE_TOUCH then
            pending.phase = PHASE_WAIT_ORIGIN_END
            if self.debugOn then
                print("Opposite toll touched for", player.Name, "pair", config.pairId)
            end
        end
    end

    self:refreshPendingInactivity(player, pending)
end

function ZoneDetector:confirmPendingTransition(player: Player, config: {pairId: number, first: boolean, zones: {}})
    local key = self:makePendingKey(player)
    local pending = self.pendingTransitions[key]
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
                print("Origin ended before opposite touch; canceling for", player.Name, "pair", config.pairId)
            end
            self:clearPendingByKey(key)
            return
        end
        if pending.phase == PHASE_WAIT_ORIGIN_END then
            pending.phase = PHASE_WAIT_OPPOSITE_END
            if self.debugOn then
                print("Origin ended; waiting for opposite end for", player.Name, "pair", config.pairId)
            end
        end
        self:refreshPendingInactivity(player, pending)
        return
    end

    pending.oppositeTouching = false
    if pending.phase == PHASE_WAIT_ORIGIN_END then
        pending.phase = PHASE_WAIT_OPPOSITE_TOUCH
        if self.debugOn then
            print("Opposite ended too early; waiting for opposite touch retry for", player.Name, "pair", config.pairId)
        end
        self:refreshPendingInactivity(player, pending)
        return
    end
    if pending.phase ~= PHASE_WAIT_OPPOSITE_END then
        self:refreshPendingInactivity(player, pending)
        return
    end
    if pending.originTouching then
        pending.phase = PHASE_WAIT_OPPOSITE_TOUCH
        pending.epoch = pending.epoch + 1
        if self.debugOn then
            print("Origin still touching at opposite end; retry required for", player.Name, "pair", config.pairId)
        end
        self:refreshPendingInactivity(player, pending)
        return
    end

    local previousZone, newZone = pending.zoneA, pending.zoneB
    self:clearPendingByKey(key)
    self:transitionPlayer(previousZone, newZone, player)
end

function ZoneDetector:transitionPlayer(previousZone: number?, newZone: number, player: Player)
    if not previousZone or not newZone then
        if self.debugOn then
            print("Previous zone or new zone is nil. Previous zone:", previousZone, "New zone:", newZone)
        end
        return
    end
    if not player then
        if self.debugOn then
            print("Player is nil when trying to transition zones. Previous zone:", previousZone, "New zone:", newZone)
        end
        return
    end
    if previousZone == newZone then
        if self.debugOn then
            print("Skipping transition with identical zones for", player.Name, previousZone)
        end
        return
    end
    if self:isDuplicateTransition(player, previousZone, newZone) then
        if self.debugOn then
            print("Skipped duplicate transition for", player.Name, previousZone, newZone)
        end
        return
    end
    if self.loadZone then
        self:markTransition(player, previousZone, newZone)
        self.loadZone(previousZone, newZone, player)
        if self.debugOn then
            print("Transitioned", player.Name, "from", previousZone, "to", newZone)
        end
    else
        if self.debugOn then
            print("No loadZone callback set. Cannot transition", player.Name, "from", previousZone, "to", newZone)
        end
    end
end

function ZoneDetector:SetCallback(callback)
    self.loadZone = callback
end

function ZoneDetector:load()
    for _num, toll in ipairs(CollectionService:GetTagged(ZoneDetector.tags.toll)) do
        self:createPair(toll)
    end

    table.insert(self.conns, Players.PlayerRemoving:Connect(function(player: Player)
        self:clearPendingForPlayer(player)
        self:clearTouchDebounceForPlayer(player)
        self:clearRecentTransitionForPlayer(player)
    end))
end

function ZoneDetector:unload()
    for _key, pending in pairs(self.pendingTransitions) do
        if pending.promise then
            pending.promise:cancel()
        end
    end
    self.pendingTransitions = {}
    self.recentTransitions = {}
    self.touchDebounce = {}

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