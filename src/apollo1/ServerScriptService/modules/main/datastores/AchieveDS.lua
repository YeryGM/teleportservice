--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local DataTypes = require(ServerScriptService.modules.general.data.types.TDataStores)
local DatastoreModule = require(script.Parent.DataStore)

type AchievementsData = DataTypes.AchievementsData
type AchievementEntry = DataTypes.AchievementEntry
type AchievementDefinition = DataTypes.AchievementDefinition
type AchievementRequirements = DataTypes.AchievementRequirements

local AchieveDS = {
    data = {
        DefaultData = {
            Achievements = {}
        }
    },
    AutoSave = true,
    SaveInterval = 120,
    playerMap = {},
    debugOn = false
}

AchieveDS.__index = AchieveDS
setmetatable(AchieveDS, { __index = DatastoreModule })

function AchieveDS.new(rootStore, player: Player)
    local self = setmetatable(rootStore:CreateNestedStore("achi", AchieveDS.data ), AchieveDS)
    self.player = player
	self.debugOn = AchieveDS.debugOn
    AchieveDS.playerMap[player.UserId] = self
    return self
end

function AchieveDS:save(): boolean
    return self:SaveAllCached()
end

function AchieveDS:getAchievement(id: DataTypes.Id): AchievementEntry?
    local data = self:LoadData(self.player.UserId) :: AchievementsData
    return data.Achievements[id] or nil

end

function AchieveDS:getAllAchievements(): { [DataTypes.Id]: AchievementEntry }
    local data = self:LoadData(self.player.UserId) :: AchievementsData
    return data.Achievements or {}
end

function AchieveDS:unlockAchievement(id: DataTypes.Id): (boolean, string?)
    return self:UpdateCachedData(self.player.UserId, function(data: AchievementsData)
        if data.Achievements and data.Achievements[id] then
            data.Achievements[id].unlocked = true
            data.Achievements[id].unlockedAt = os.time()
        end
        return data, nil
    end)
end

function AchieveDS:addAchievement(id: DataTypes.Id, achievementData: AchievementDefinition?): (boolean, string?)
    local normalizedRequirements: AchievementRequirements = {}
    local normalizedMetadata: DataTypes.Metadata = {}
    if achievementData then
        local typedData = achievementData :: any
        normalizedRequirements = (typedData.requirements :: AchievementRequirements?) or {}
        normalizedMetadata = (typedData.metadata :: DataTypes.Metadata?) or {}
    end
    return self:UpdateCachedData(self.player.UserId, function(data: AchievementsData)
        if not data.Achievements then 
            data.Achievements = {} 
        end
        -- Create achievement structure if it doesn't exist
        if not data.Achievements[id] then
            data.Achievements[id] = {
                id = id,
                requirements = normalizedRequirements,
                unlocked = false,
                unlockedAt = nil,
                metadata = normalizedMetadata
            }
        end
        return data, nil
    end)
end

function AchieveDS:getRequirements(id: DataTypes.Id): AchievementRequirements?
    local data = self:LoadData(self.player.UserId) :: AchievementsData
    if data.Achievements and data.Achievements[id] then
        return data.Achievements[id].requirements or {}
    end
    return nil
end

function AchieveDS:addRequirement(id: DataTypes.Id, requirementKey: DataTypes.AchievementRequirementKey, requirementValue: boolean?): (boolean, string?)
    local normalizedValue = requirementValue == true
    return self:UpdateCachedData(self.player.UserId, function(data: AchievementsData)
        if not data.Achievements then 
            data.Achievements = {} 
        end
        if not data.Achievements[id] then
            data.Achievements[id] = {
                id = id,
                requirements = {},
                unlocked = false,
                unlockedAt = nil,
                metadata = {}
            }
        end
        
        data.Achievements[id].requirements[requirementKey] = normalizedValue
        return data, nil
    end)
end

function AchieveDS:completeRequirement(id: DataTypes.Id, requirementKey: DataTypes.AchievementRequirementKey): (boolean, string?)
    return self:UpdateCachedData(self.player.UserId, function(data: AchievementsData)
        if data.Achievements and data.Achievements[id] and data.Achievements[id].requirements then
            data.Achievements[id].requirements[requirementKey] = true
            
            -- Check if all requirements are complete
            local allComplete = true
            for _, value in pairs(data.Achievements[id].requirements) do
                if value ~= true then
                    allComplete = false
                    break
                end
            end
            
            -- If all requirements are complete, unlock the achievement
            if allComplete and not data.Achievements[id].unlocked then
                data.Achievements[id].unlocked = true
                data.Achievements[id].unlockedAt = os.time()
            end
        end
        return data, nil
    end)
end

function AchieveDS:deleteRequirement(id: DataTypes.Id, requirementKey: DataTypes.AchievementRequirementKey): (boolean, string?)
    return self:UpdateCachedData(self.player.UserId, function(data: AchievementsData)
        if data.Achievements and data.Achievements[id] and data.Achievements[id].requirements then
            data.Achievements[id].requirements[requirementKey] = nil
        end
        return data, nil
    end)
end

function AchieveDS:deleteAchievement(id: DataTypes.Id): (boolean, string?)
    return self:UpdateCachedData(self.player.UserId, function(data: AchievementsData)
        if data.Achievements then
            data.Achievements[id] = nil
        end
        return data, nil
    end)
end

function AchieveDS:isAchievementUnlocked(id: DataTypes.Id): boolean
    local data = self:LoadData(self.player.UserId) :: AchievementsData
    if data.Achievements and data.Achievements[id] then
        return data.Achievements[id].unlocked or false
    end
    return false
end

function AchieveDS:unload()
    AchieveDS.playerMap[self.player.UserId] = nil
end

return AchieveDS