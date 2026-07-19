local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local folder = Instance.new("Folder")
folder.Name = "TrajectoryPreview"
folder.Parent = Workspace
local LocalPlayer = Players.LocalPlayer

local TrajectoryPreview = {}
TrajectoryPreview.__index = TrajectoryPreview

function TrajectoryPreview.new(config)
	local self = setmetatable({}, TrajectoryPreview)
	self.Config = config
	self.Points = {}
	self.PartPool = {}
	self.Visible = false
	self.Container = Instance.new("Folder")
	self.Container.Name = "TrajectoryPreview"
	self.Container.Parent = folder
	return self
end

function TrajectoryPreview:DefaultTrajectory(origin: Vector3, velocity: Vector3, gravity: Vector3, time: number): Vector3
	return origin + (velocity * time) + (0.5 * gravity * time * time)
end

function TrajectoryPreview:CalculateTrajectoryPoints(
	origin: Vector3,
	velocity: Vector3,
	gravity: Vector3,
	maxTime: number,
	resolution: number,
	trajectory
): {Vector3}
	local points = {}
	local actualTime = 0
	while actualTime <= maxTime do
		local position = trajectory(origin, velocity, gravity, actualTime) 
		or self:DefaultTrajectory(origin, velocity, gravity, actualTime)
		table.insert(points, position)
		actualTime += resolution
	end
	return points
end

function TrajectoryPreview:Update(origin: Vector3, direction: Vector3, power: number)
	if not self.Config.TrajectoryVisible then return end
	local velocity = direction * (self.Config.Speed * power)
	local points = self:CalculateTrajectoryPoints(
		origin,
		velocity,
		self.Config.Gravity,
		self.Config.Lifetime,
		0.1,
		self.Config.TrajectoryFunction
	)
	for i = #points + 1, #self.Points do
		if self.Points[i] then
			self.Points[i].Parent = nil
		end
	end
	local params = RaycastParams.new()
	local filterList = {self.Container}
	if LocalPlayer.Character then
		table.insert(filterList, LocalPlayer.Character)
	end
	params.FilterDescendantsInstances = filterList
	params.FilterType = Enum.RaycastFilterType.Exclude
	
	for i, point in points do
		local sphere = self:getOrCreatePoint(i)
		sphere.Position = point
		sphere.Color = self.Config.TrajectoryColor or Color3.new(1, 1, 0)
		sphere.Parent = self.Container
		
		if i > 1 then
			local prevPoint = points[i - 1]
			local newDirection = (point - prevPoint).Unit
			local distance = (point - prevPoint).Magnitude
			
			local result = Workspace:Raycast(prevPoint, newDirection * distance, params)
			if result then
				sphere.Position = result.Position
				-- Hide remaining points
				for j = i + 1, #self.Points do
					if self.Points[j] then
						self.Points[j].Parent = nil
					end
				end
				break
			end
		end
	end
	self.Visible = true
end

function TrajectoryPreview:getOrCreatePoint(index: number): Part
	if self.Points[index] then
		return self.Points[index]
	end
	local sphere = table.remove(self.PartPool)
	if not sphere then
		sphere = Instance.new("Part")
		sphere.Name = "TrajectoryPoint"
		sphere.Shape = Enum.PartType.Ball
		sphere.Size = Vector3.new(0.2, 0.2, 0.2)
		sphere.Anchored = true
		sphere.CanCollide = false
		sphere.Transparency = 0.5
		sphere.Material = Enum.Material.Neon
	end
	self.Points[index] = sphere
	return sphere
end

function TrajectoryPreview:Clear()
	for _, point in self.Points do
		if point and point.Parent then
			point.Parent = nil
			table.insert(self.PartPool, point)
		end
	end
	self.Points = {}
	self.Visible = false
end

function TrajectoryPreview:Show()
	if self.Container.Parent == nil then
		local parentFolder = Workspace:FindFirstChild("general")
		if parentFolder then
			parentFolder = parentFolder:FindFirstChild("bombs")
		end
		self.Container.Parent = parentFolder or Workspace
	end
	self.Visible = true
end

function TrajectoryPreview:Hide()
	self:Clear()
	self.Container.Parent = nil
	self.Visible = false
end

function TrajectoryPreview:Destroy()
	self:Clear()
	for _, part in self.PartPool do
		if part then
			part:Destroy()
		end
	end
	self.PartPool = {}
	if self.Container then
		self.Container:Destroy()
	end
end

return TrajectoryPreview