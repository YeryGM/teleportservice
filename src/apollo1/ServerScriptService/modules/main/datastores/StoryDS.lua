--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local dataFolder = ServerScriptService.modules.general.data
local DataTypes = require(dataFolder.types.TDataStores)
local DataStore = require(script.Parent.DataStore)

type StoryData = DataTypes.StoryData
type StoryDetailData = DataTypes.StoryDetailData

local StoryDS = {
    data = {
        DefaultData = {
            Chapters = {}
        }
    },
    playerMap = {},
    debugOn = false
}
StoryDS.__index = StoryDS
setmetatable(StoryDS, { __index = DataStore })

function StoryDS.new(rootStore, player: Player)
    local self = setmetatable(rootStore:CreateNestedStore("story", StoryDS.data), StoryDS)
    self.player = player
    self.debugOn = StoryDS.debugOn
    StoryDS.playerMap[player.UserId] = self
    return self
end

function StoryDS:save(): boolean
    return self:SaveAllCached()
end

function StoryDS:addChapterDetail(chapter: DataTypes.StoryChapterId, detailId: DataTypes.StoryDetailId, detailData: StoryDetailData): (boolean, string?)
    if type(detailData) ~= "table" then
        return false, "Invalid detail data"
    end
    return self:UpdateCachedData(self.player.UserId, function(data: StoryData)
        if not data.Chapters then 
            data.Chapters = {}
        end
        if not data.Chapters[chapter] then
            data.Chapters[chapter] = {
                details = {}
            }
        end
        data.Chapters[chapter].details[detailId] = detailData
        return data, nil
    end)
end

function StoryDS:getChapterDetails(chapter: DataTypes.StoryChapterId): { [DataTypes.StoryDetailId]: StoryDetailData }
    local data = self:LoadData(self.player.UserId) :: StoryData
    if data.Chapters and data.Chapters[chapter] then
        return data.Chapters[chapter].details or {}
    end
    return {}
end

function StoryDS:getChapterDetail(chapter: DataTypes.StoryChapterId, detailId: DataTypes.StoryDetailId): StoryDetailData?
    local data = self:LoadData(self.player.UserId) :: StoryData
    if data.Chapters and data.Chapters[chapter] then
        return data.Chapters[chapter].details[detailId] or nil
    end
    return nil
end

function StoryDS:deleteChapterDetail(chapter: DataTypes.StoryChapterId, detailId: DataTypes.StoryDetailId): (boolean, string?)
    return self:UpdateCachedData(self.player.UserId, function(data: StoryData)
        if data.Chapters and data.Chapters[chapter] then
            data.Chapters[chapter].details[detailId] = nil
        end
        return data, nil
    end)
end

function StoryDS:unload()
    StoryDS.playerMap[self.player.UserId] = nil
end

return StoryDS