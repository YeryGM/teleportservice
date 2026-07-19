local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalsC = require(ReplicatedStorage.modules.general.data.SignalsC)
SignalsC.create()

local schemer = require(script.Parent.main.loading.SchemerC)
schemer:load()