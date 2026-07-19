local Players = game:GetService("Players")

local multiplierMap = {
    [1] = 1.1,
    [2] = 1.25,
    [3] = 1.4,
    [4] = 1.55,
    [5] = 1.7,
}

local Overview = {}
Overview.__index = Overview

function Overview.new(player:Player)
    local self = setmetatable({}, Overview)
    self.player = player
    self.credits = {
        found = 0,
        earned = 0,
    }
    return self
end

function Overview:getCredits()
    return {
        found = self.credits.found,
        earned = self.credits.earned,
        subtotal = self.credits.found + self.credits.earned
    }
end

function Overview:getOverview()
    return {
        credits = self:getCredits(),
        multiplier = self:getMultiplier(),
        total = self:getCredits().subtotal * self:getMultiplier()
    }
end

function Overview:getMultiplier()
    local friendsCount = 0
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer.UserId ~= self.player.UserId and otherPlayer:IsFriendsWith(self.player.UserId) then
            friendsCount = friendsCount + 1
        end
    end
    return multiplierMap[friendsCount] or 1
end

return Overview