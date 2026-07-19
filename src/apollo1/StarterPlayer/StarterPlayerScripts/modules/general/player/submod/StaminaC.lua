local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.modules.general.data.Configs)
local UISStamina = require(script.Parent.Parent.Parent.Parent.ui.services.UISStamina)

local useStamina: RemoteFunction = ReplicatedStorage.funcs.general.player.useStamina
local staminaModifier: RemoteEvent = ReplicatedStorage.events.general.player.staminaModifier

local Stamina = {
    debugOn = false,
    conns = {},
}
Stamina.__index = Stamina

function Stamina.new(onDrained:(() -> ())?)
    local self = setmetatable({}, Stamina)
    local config = Config.getConfig().player.stamina
    self.maxStamina = config.staminaMax
    self.currentStamina = config.staminaMax
    self.drainRate = config.drainRate
    self.regenRate = config.regenRate
    self.onDrained = onDrained
    self.isFadingIn = false
    self.isFadingOut = false
    self.fadeStartTime = 0
    self.shouldCheck = false
    self.onUse = false
    self.uiVisible = false
    self:load()
    return self
end

function Stamina:GetCurrentStamina()
    return self.currentStamina
end

function Stamina:SetCurrentStamina(value: number)
    self.currentStamina = math.clamp(value, 0, self.maxStamina)
end

function Stamina:drainStamina(deltaTime:number)
    if self.currentStamina <= 0 then return end
    local drainAmount = self.drainRate * deltaTime
    self:useStamina(drainAmount)
end

function Stamina:regenStamina(deltaTime:number)
    if self.currentStamina >= self.maxStamina then return end
    local ok = useStamina:InvokeServer(false)
    if not ok then
        if self.debugOn then
            warn("Server denied stamina regen request")
        end
        return
    end
    local regenAmount = self.regenRate * deltaTime
    self:SetCurrentStamina(self.currentStamina + regenAmount)
end

function Stamina:useStamina(amount: number)
    if amount <= 0 then
        if self.debugOn then
            warn("Attempted to use non-positive stamina amount: " .. tostring(amount))
        end
        return 
    end
    if amount > self.currentStamina then
       if self.debugOn then
            warn("Not enough stamina to use: " .. tostring(amount) .. " requested, " .. tostring(self.currentStamina) .. " available")
        end
        return
    end
    local ok = useStamina:InvokeServer(true)
    if not ok then -- not draining

        return
    end
    self:SetCurrentStamina(self.currentStamina - amount)
end

function Stamina:updateUI()
    UISStamina.updateStamina(self.currentStamina)
    UISStamina.updateMaxStamina(self.maxStamina)
end

function Stamina:modifier(newMaxStamina: number, newDrainRate: number, newRegenRate: number)
    self.maxStamina = newMaxStamina
    self.currentStamina = math.clamp(self.currentStamina, 0, self.maxStamina)
    self.drainRate = newDrainRate
    self.regenRate = newRegenRate
end

function Stamina:setShouldCheck(value:boolean)
    self.shouldCheck = value
end

function Stamina:setOnUse(value:boolean)
    self.onUse = value
end

function Stamina:load()
    local conn = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.shouldCheck then return end
        if self.onUse then
            self:drainStamina(deltaTime)
        else
            self:regenStamina(deltaTime)
        end
        self:updateUI()
    end)
    table.insert(self.conns, conn)
    local conn2 = staminaModifier.OnClientEvent:Connect(function(newMaxStamina:number, newDrainRate:number, newRegenRate:number)
        self:modifier(newMaxStamina, newDrainRate, newRegenRate)
    end)
    table.insert(self.conns, conn2)
end

function Stamina:unload()
    for _, conn in ipairs(self.conns) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(self.conns)
end

return Stamina