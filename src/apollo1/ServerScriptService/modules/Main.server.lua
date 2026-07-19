local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signals = require(ReplicatedStorage.modules.general.data.Signals)
Signals.create()

local schemer = require(script.Parent.main.loading.Schemer)
schemer:load()