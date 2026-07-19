local CreditsDS = require(script.Parent.Parent.Parent.datastores.CreditsDS)

local Credits = {
    debugOn = true,
}

local function validate(player: Player, amount: number): (boolean, any?, string?)
    if not player or not player:IsA("Player") then
        if Credits.debugOn then
            warn("Invalid player object for adding credits.")
        end
        return false, nil, "Invalid player."
    end
    if not amount or type(amount) ~= "number" or amount <= 0 then
        if Credits.debugOn then
            warn("Invalid amount for adding credits to player:", player.Name)
        end
        return false, nil, "Invalid amount."
    end
    local creditsDSInstance = CreditsDS.playerMap[player.UserId]
    if not creditsDSInstance then
        if Credits.debugOn then
            warn("No credits data store found for player:", player.Name)
        end
        return false, nil, "Player data store not found."
    end
    return true, creditsDSInstance, nil
end

local function addCreditsToPlayer(player: Player, amount: number, reason: string)
    local valid, creditsDSInstance, _ = validate(player, amount)
    if not valid then
        return false
    end
    local success, added, err = pcall(function()
        return creditsDSInstance:addCredits(amount, reason)
    end)
    if not success or not added then
        if Credits.debugOn then
            warn("Failed to grant credits for player:", player.Name, "Error:", (err or ""))
        end
        return false
    end
    return true
end

function Credits.validatePurchase(player: Player, _productId: number, data: {amount: number}?, _productData)
    local ok, _creditsDSInstance, reason = validate(player, data and data.amount or 1)
    if not ok then
        return false, reason
    end
    return true
end

function Credits.grantItem(player: Player, _productId: number, productData, data: {amount: number}?)
    local metadata = productData and productData.Metadata or {}
    local baseAmount = metadata.amount or 0
    local multiplier = data and data.amount or 1
    local totalAmount = baseAmount * multiplier
    if totalAmount <= 0 then
        if Credits.debugOn then
            warn("Invalid credit amount for grant:", totalAmount)
        end
        return false
    end
    return addCreditsToPlayer(player, totalAmount, productData and productData.Name or "Credits")
end
return Credits