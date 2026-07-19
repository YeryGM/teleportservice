local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UISQte = require(script.Parent.Parent.Parent.Parent.ui.services.UISQte) 
local Qte = require(script.Parent.Qte)

local RepeatedPressOk:RemoteFunction = ReplicatedStorage.funcs.general.player.RepeatedPressOk

local RepeatedPress = {}
RepeatedPress.__index = RepeatedPress
setmetatable(RepeatedPress, {__index = Qte})

function RepeatedPress.new(onSuccess, onFailure, data, qteEnum)
    local self = setmetatable(Qte.new(onSuccess, onFailure, data, qteEnum), RepeatedPress)
    self.requiredPresses = self.config.requiredPresses or 10
    self.keys = {}
    self.currentPresses = {}
    self:load()
    return self
end

function RepeatedPress:load()
    for keycode, letter in pairs(self.config.keys) do
        self.keys[keycode] = letter
        self.currentPresses[keycode] = 0
    end
    self:updateUI()
end

function RepeatedPress:unload()
    UISQte.setValidator(nil)
    UISQte.setQteData(nil)
end

function RepeatedPress:validate(keycode)
	if self.keys[keycode] then
        local success = RepeatedPressOk:InvokeServer(keycode)
        if not success then return end
		self.currentPresses[keycode] = (self.currentPresses[keycode]) + 1
		self:updateUI()
		if self:checkCompletion() then
            self.completed = true
            self.onSuccess()
        end
	end
end

function RepeatedPress:checkCompletion(): boolean
    for keycode, _ in pairs(self.keys) do
        if (self.currentPresses[keycode] or 0) < self.requiredPresses then
            return false
        end
    end
    return true
end

function RepeatedPress:updateUI()
    UISQte.setValidator(function(keycode): boolean
        return self:validate(keycode)
    end)
    UISQte.setQteData({
        configKey = self.configKey,
        requiredPresses = self.requiredPresses,
        currentPresses = self.currentPresses,
        keys = self.keys,
    })
end

return RepeatedPress