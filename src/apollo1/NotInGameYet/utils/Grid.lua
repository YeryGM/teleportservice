local Players = game:GetService("Players")

export type GridTile = {
	part: BasePart,
	row: number,
	column: number,
	group: string,
	callbacks: { onEnter: ((tile: GridTile, player: Player) -> ())?, onExit: ((tile: GridTile, player: Player) -> ())? }?
}

local Grid = {
	debugOn = false,
}
Grid.__index = Grid

local function applyTilePhysics(part: BasePart)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = true
	part.Massless = true
	part.CastShadow = false
	part.Transparency = 1
	part.Reflectance = 0
end

function Grid.new(spawnParts:{BasePart}, parts: { BasePart })
	local self = setmetatable({}, Grid)
	self.connections = {}
	self.tiles = {}  
	self.tilesR= {}
	self.groupCallbacks = {} --actions per group
	self.activatedGroups = {}
	self.parts = parts  
	self:createTiles()
	self.spawnParts = spawnParts
	if self.spawnParts then
		self.spawnLookup = {}
		self:setUpspawnParts(self.spawnParts)
	end
	return self
end

function Grid:createTiles()
	for _, part in self.parts do
		self:createTile(part)
	end
end

function Grid:createTile(part: BasePart)
	if not part:IsA("BasePart") then return end
	local row = part:GetAttribute("row")
	local column = part:GetAttribute("column")
	local tile: GridTile = {
		part    = part,
		row     = row,
		column  = column,
		group   = nil,
	}
	applyTilePhysics(part)
	if not self.tiles[row] then 
		self.tiles[row] = {} 
	end
	if not self.tilesR[column] then 
		self.tilesR[column] = {} 
	end
	if not self.tiles[row][column] then
		self.tiles[row][column] = tile
		self.tilesR[column][row] = tile
	else
		if self.debugOn then
			warn("Duplicate tile at row " .. row .. ", column " .. column)
		end
	end

	local touchedConn = part.Touched:Connect(function(hit: BasePart)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then return end
		--group
		if self.groupCallbacks[tile.group] then
			if self.activatedGroups[tile.group] then return end
			self.activatedGroups[tile.group] = true
			local ok, err = pcall(self.groupCallbacks[tile.group].onEnter, tile, player)
			if not ok then 
				if self.debugOn then
					 warn("onEnter error for group '" .. tile.group .. "': " .. err) 
				end
			end
		end
		--tile
		if tile.callbacks and tile.callbacks.onEnter then
			local ok, err = pcall(tile.callbacks.onEnter, tile, player)
			if not ok then 
				if self.debugOn then
					 warn("onEnter error for tile at row " .. row .. ", column " .. column .. ": " .. err) 
				end
			end
		end 
	end)

	local touchEndedConn = part.TouchEnded:Connect(function(hit: BasePart)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then return end
		if self.groupCallbacks[tile.group] then
			if self.activatedGroups[tile.group] then return end
			self.activatedGroups[tile.group] = false
			local ok, err = pcall(self.groupCallbacks[tile.group].onExit, tile, player)
			if not ok then 
				if self.debugOn then
					 warn("onExit error for group '" .. tile.group .. "': " .. err) 
				end
			end
		end
		if tile.callbacks and tile.callbacks.onExit then
			local ok, err = pcall(tile.callbacks.onExit, tile, player)
			if not ok then 
				if self.debugOn then
					 warn("onExit error for tile at row " .. row .. ", column " .. column .. ": " .. err) 
				end
			end
		end 
	
	end)
	table.insert(self.connections, touchedConn)
	table.insert(self.connections, touchEndedConn)
end

function Grid:setTileGroup(row: number, column: number, group:number)
	if self.tiles[row] and self.tiles[row][column] then
		self.tiles[row][column].group = group
	else
		if self.debugOn then
			warn("Trying to set group for non-existent tile at row " .. row .. ", column " .. column)
		end
	end
end

function Grid:setTileCallbacks(row: number, column: number, callbacks)
	if self.tiles[row] and self.tiles[row][column] then
		self.tiles[row][column].callbacks = callbacks
	else
		if self.debugOn then
			warn("Trying to set callbacks for non-existent tile at row " .. row .. ", column " .. column)
		end
	end
end

function Grid:setGroupCallbacks(group:number, callbacks)
	self.groupCallbacks[group] = callbacks
end

function Grid:setUpspawnParts(spawnParts: {BasePart})
    for _, spawnPart in pairs(spawnParts) do
        local row = spawnPart:GetAttribute("row")
        local col = spawnPart:GetAttribute("column")
		applyTilePhysics(spawnPart)
        if row and col then
            if not self.spawnLookup[row] then
                self.spawnLookup[row] = {}
            end
            self.spawnLookup[row][col] = spawnPart
        end
    end
end
function Grid:unload()
	for _, conn in self.connections do
		conn:Disconnect()
	end
	self.connections = {}
	self.tiles = {}
	self.tilesR = {}
	self.groupCallbacks = {}
	self.activatedGroups = {}
	for _, part in self.parts do
		part:Destroy()
	end
end

return Grid
