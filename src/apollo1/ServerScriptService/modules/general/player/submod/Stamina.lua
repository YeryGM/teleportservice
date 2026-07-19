local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Configs = require(ReplicatedStorage.modules.general.data.Configs)

local remoteEvents = ReplicatedStorage.events.general.player
local toggleShouldCheck: RemoteEvent = remoteEvents.toggleShouldCheck
local staminaModifier: RemoteEvent = remoteEvents.staminaModifier

local Stamina = {
    debugOn = false,
    conns = {},
}
Stamina.__index = Stamina

function Stamina.new(player:Player)
    local self = setmetatable({}, Stamina)
    local config = Configs.getConfig().player.stamina
    self.maxStamina = config.maxStamina
    self.currentStamina = config.maxStamina
    self.regenRate = config.regenRate 
    self.drainRate = config.drainRate 
    self.player = player
    self.isDraining = false
    self.shouldCheck = false
    self.loaded = false
    self:load()
    return self
end

function Stamina:load()
    if self.loaded then
        return
    end
    if not self.shouldCheck then
        return
    end
    local conn = RunService.Heartbeat:ConnectParallel(function(deltaTime: number)
        if not self.shouldCheck then
            return
        end
        self:handleStamina(deltaTime)
    end)
    table.insert(self.conns, conn)
    self.loaded = true
end

function Stamina:unload()
    for _, conn:RBXScriptConnection in pairs(self.conns) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(self.conns)
    self.conns = {}
    
    local config = Configs.getConfig().player.stamina
    self.maxStamina = config.maxStamina
    self.currentStamina = config.maxStamina
    self.regenRate = config.regenRate 
    self.drainRate = config.drainRate 
    self.isDraining = false
    self.shouldCheck = false
    self.loaded = false
end

function Stamina:useStamina(amount: number)
    if amount <= 0 then
        return 
    end
    if amount > self.currentStamina then
        return
    end
    self.currentStamina = math.clamp(self.currentStamina - amount, 0, self.maxStamina)
end

function Stamina:regenStamina(deltaTime: number)
    if self.isDraining then return end
    if self.currentStamina >= self.maxStamina then return end
    local regenAmount = self.regenRate * deltaTime
    self.currentStamina = math.clamp(self.currentStamina + regenAmount, 0, self.maxStamina)
end

function Stamina:getCurrentStamina():number
    return self.currentStamina
end

function Stamina:drainStamina(deltaTime:number)
    if not self.isDraining then return end
    if self.currentStamina <= 0 then 
        self.isDraining = false
        return 
    end
    local drainAmount = self.drainRate * deltaTime
    self:useStamina(drainAmount)
end

function Stamina:handleStamina(deltaTime:number)
    if self.isDraining then
        self:drainStamina(deltaTime)
    else
        self:regenStamina(deltaTime)
    end
end

function Stamina:onUse(shouldDrain:boolean): boolean
    self.isDraining = shouldDrain
    return self.isDraining
end

function Stamina:setShouldCheck(value:boolean)
    self.shouldCheck = value
    toggleShouldCheck:FireClient(self.player, value)
    if self.shouldCheck then
        self:load()
    else
        self:unload()
    end
end

function Stamina:onModify(isApplying:boolean, maxStamina:number, regenRate:number, drainRate:number): boolean
    if isApplying then
        self.maxStamina = maxStamina
        self.regenRate = regenRate
        self.drainRate = drainRate
    else
        local config = Configs.getConfig().player.stamina
        self.maxStamina = config.maxStamina
        self.regenRate = config.regenRate
        self.drainRate = config.drainRate
    end
    staminaModifier:FireClient(self.maxStamina, self.regenRate, self.drainRate)
    return true
end

return Stamina