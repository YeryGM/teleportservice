local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UISQte = require(script.Parent.Parent.Parent.Parent.ui.services.UISQte)
local Qte = require(script.Parent.Qte)

local OrderedPressOk: RemoteFunction = ReplicatedStorage.funcs.general.player.OrderedPressOk

type sequence = {Enum.KeyCode}
type colorMap = {[Enum.KeyCode] : Color3}

local OrderedPress = {}
OrderedPress.__index = OrderedPress
setmetatable(OrderedPress, {__index = Qte})

function OrderedPress.new(onSuccess, onFailure, data, qteEnum:number)
    local self = setmetatable(Qte.new(onSuccess, onFailure, data, qteEnum), OrderedPress)
    local sequence:sequence = self.config.sequence
    self.sequence = sequence
    self.currentIndex = 1
    self.retryOnFailure = self.config.retryOnFailure or false
    self.keySet = self.config.colorMap 
    self:load()
    return self
end

function OrderedPress:load()
    self:updateUI()
end

function OrderedPress:unload()
    UISQte.setValidator(nil)
    UISQte.setQteData(nil)
end

function OrderedPress:validate(keycode:Enum.KeyCode)
    if not self.keySet[keycode] then return end
    local success = OrderedPressOk:InvokeServer(keycode)
    if success then
        self.currentIndex += 1
        if self.currentIndex > #self.sequence then
            self.completed = true
            self.onSuccess()
            return
        end
        self:updateUI()
    else
        if self.retryOnFailure then
            self.currentIndex = 1
            self:updateUI()
        else
            self.completed = true
            self.onFailure()
        end
    end
end

function OrderedPress:updateUI()
    UISQte.setValidator(function(keycode:Enum.KeyCode)
        return self:validate(keycode)
    end)
    UISQte.setQteData({
        sequence = self.sequence,
        currentIndex = self.currentIndex,
        colorMap = self.keySet,
    })
end

return OrderedPress