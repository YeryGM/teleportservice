local ServerScriptService = game:GetService("ServerScriptService")
local bindableFunc = ServerScriptService.funcs.general.player
local revivePlayer: BindableFunction = bindableFunc.revivePlayer
local canPlayerRevive: BindableFunction = bindableFunc.canPlayerRevive

local Revive = {
    debugOn = true,
}


function Revive.validatePurchase(player: Player, _productId: number, _data: {amount: number}?, _productData)
    if not player or not player:IsA("Player") then
        if Revive.debugOn then
            warn("Invalid player for revive purchase validation")
        end
        return false, "invalid player"
    end
    local canRevive = canPlayerRevive:Invoke(player.UserId)
    if not canRevive then
        if Revive.debugOn then
            warn("Player", player.Name, "cannot revive at this time")
        end
        return false, "cannot revive"
    end
    return true
end

function Revive.grantItem(player: Player, _productId: number, _productData, _data: {amount: number}?)
    local reviveSuccess = revivePlayer:Invoke(player.UserId)
    if not reviveSuccess then
        if Revive.debugOn then
            warn("Failed to revive player", player.Name)
        end
        return false
    end
    return true
end
return Revive