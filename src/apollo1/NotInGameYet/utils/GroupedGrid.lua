local Grid = require(script.Parent.Grid)

local GroupedGrid = {}

function GroupedGrid.new(spawnParts: {BasePart}, parts: {BasePart},config)
    local self = setmetatable(Grid.new(spawnParts, parts), {__index = GroupedGrid})
    self.probs = config.probs or {}
    return self
end

function GroupedGrid:createGroups()
    local skipRows = {}
    for index, _row in self.tiles do
        if skipRows[index] then continue end
        local groupType = self:getRandomBasedOnWeight(self.probs)
        if self.creators[groupType] then
            local skips = self.creators[groupType](index) 
            if skips then
                for _, rowIndex in skips do
                    skipRows[rowIndex] = true
                end
            end
        else
            if self.debugOn then
                warn("No creator function defined for group type " .. groupType)
            end
        end     
    end
end

function GroupedGrid:getRandomBasedOnWeight(probabilities)
	local totalWeight = 0
	for _, weight in pairs(probabilities) do
		totalWeight += weight
	end
	local pick = Random.new():NextNumber(0, totalWeight)
	local cumulative = 0
    local selectedGroup = nil
	for number, weight in pairs(probabilities) do
		cumulative += weight
		if pick <= cumulative then
			selectedGroup = number
			break
		end
	end
	return selectedGroup
end

function GroupedGrid:setCreators(creators)
    self.creators = creators
end

function GroupedGrid:unload()
    self.groupCallbacks = {}
    self.activatedGroups = {}
    Grid.unload(self)
end

return GroupedGrid