local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeathActions = require(script.Parent.Parent.store.death.DeathActions)
local UiActions = require(script.Parent.Parent.store.ui.UiActions)

local remoteFuncs = ReplicatedStorage.funcs.general.player
local requestOverview:RemoteFunction = remoteFuncs.requestOverview

local remoteEvents = ReplicatedStorage.events.general.player
local returnToLobby: RemoteEvent = remoteEvents.returnToLobby
local playAgainEvent: RemoteEvent = remoteEvents.playAgain

local bindableFuncs = script.Parent.Parent.Parent.Parent.funcs.general.player
local requestRevive: BindableFunction = bindableFuncs.requestRevive

local bindableEvents = script.Parent.Parent.Parent.Parent.events.general.player
local changeSpectator: BindableEvent = bindableEvents.spectateStep

local DeathService = {}

function DeathService.requestOverview()
    local ok, overview = pcall(function()
        return requestOverview:InvokeServer()
    end)
    if ok and overview then
        DeathActions.setOverviewData(overview)
    end
end

function DeathService.requestRevive()
    local ok, revived = pcall(function()
        return requestRevive:Invoke()
    end)
    if ok and revived then
        UiActions.setGameplay()
    end
end

function DeathService.requestReturnToLobby()
    returnToLobby:FireServer()
end

function DeathService.requestPlayAgain()
    playAgainEvent:FireServer()
end

function DeathService.requestSpectateStep(direction:number)
    changeSpectator:Fire(direction)
end

function DeathService.spectateLeft()
    DeathService.requestSpectateStep(-1)
end

function DeathService.spectateRight()
    DeathService.requestSpectateStep(1)
end

function DeathService.toggleOverview()
    local state = DeathActions.getState()
    if state.ui.overviewOpen then
        DeathActions.setOverviewOpen(false)
    else
        DeathActions.setOverviewOpen(true)
    end
end

function DeathService.setSpectator(targetName:string)
    DeathActions.setSpectator(targetName)
end

return DeathService
