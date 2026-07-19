local GroupedGrid = require(script.Parent.GroupedGrid)

local FallingGrid = {}
FallingGrid.__index = FallingGrid

function FallingGrid.new(spawnParts: {BasePart}, parts: {BasePart}, config)
    local self = setmetatable(
        GroupedGrid.new(spawnParts, parts, config),
        { __index = FallingGrid }
    )
    self.groupConfigs = config.groups or {}
    self.firedGroups  = {}
    self:setUp()
    return self
end

function FallingGrid:setUp()
    self:setUpspawnParts(self.spawnParts or {})
    self:setUpCreators()
    self:createGroups()
    self:wireGroupTouches()
end

function FallingGrid:setUpCreators()
    if not self.groups then 
        self.groups = {} 
    end
    local creators = {}
    for groupType, groupConfig in pairs(self.groupConfigs) do
        self.probs[groupType] = groupConfig.probability
        if not self.groups[groupType] then 
            self.groups[groupType] = {} 
        end
        local minN     = groupConfig.minN or 1
        local maxN     = groupConfig.maxN or 1
        local skipRows = groupConfig.skipRows
        creators[groupType] = function(rowIndex)
            --single row group
            if #skipRows == 0 then
                local row = self.tiles[rowIndex]
                if not row then return end
                local tileList = {}
                for _, tile in row do
                    table.insert(tileList, tile)
                end
                if #tileList == 0 then return end
                local n = math.random(minN, math.max(minN, math.min(maxN, #tileList)))
                for i = #tileList, 2, -1 do
                    local j = math.random(i)
                    tileList[i], tileList[j] = tileList[j], tileList[i]
                end
                --all tiles assigned to group so all activate, only first n tiles are added to group list for callbacks
                for i = 1, #tileList do
                    local tile = tileList[i]
                    self:setTileGroup(tile.row, tile.column, groupType)
                    if i <= n then
                        table.insert(self.groups[groupType], tile)
                    end
                end
                return
            else 
                --multi-row group
                local rowsToGroup = {rowIndex}
                for _, offset in pairs(skipRows) do
                    table.insert(rowsToGroup, rowIndex + offset)
                end
                local groupedTiles = {}
                for _, r in pairs(rowsToGroup) do
                    local row = self.tiles[r]
                    if not row then continue end
                    for _, tile in pairs(row) do
                        self:setTileGroup(tile.row, tile.column, groupType)
                        table.insert(groupedTiles, tile)
                    end
                end
                self.groups[groupType] = groupedTiles
                return skipRows
            end
        end
    end
    self:setCreators(creators)
end

function FallingGrid:wireGroupTouches()
    for groupType in pairs(self.groupConfigs) do
        local nextGroup = groupType + 1
        self:setGroupCallbacks(groupType, {
            onEnter = function(_tile, _player)
                self:triggerGroup(nextGroup)
            end,
            onExit = function() end,
        })
    end
end

function FallingGrid:triggerGroup(groupType: number)
    if self.firedGroups[groupType] then return end
    local groupConfig = self.groupConfigs[groupType]
    if not groupConfig or not groupConfig.onFall then return end
    self.firedGroups[groupType] = true
    local activeTiles = self.groups[groupType] or {}
    --this is where the models are spawned 
    groupConfig.onFall(activeTiles, self.spawnLookup) 
end

function FallingGrid:setGroupOnFall(groupType, callback)
   self.groupConfigs[groupType].onFall = callback
end

function FallingGrid:unload()
    self.firedGroups = {}
    GroupedGrid.unload(self)
end

return FallingGrid