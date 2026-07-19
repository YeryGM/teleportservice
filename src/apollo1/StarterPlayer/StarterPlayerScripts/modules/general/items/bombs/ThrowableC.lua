local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local TrajectoryPreview = require(script.Parent.TrajectoryPreview)

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ThrowableClient = {}
ThrowableClient.__index = ThrowableClient

function ThrowableClient.new(config, uid:string, remoteEvent: RemoteEvent)
	local self = setmetatable({}, ThrowableClient)
	self.Config = config
	self.uid = uid
	self.RemoteEvent = remoteEvent
	self.Equipped = false
	self.Holding = false
	self.HoldStartTime = 0
	self.ChargePower = 0
	self.MaxChargeTime = config.MaxChargeTime or 2 
	self.TrajectoryPreview = TrajectoryPreview.new(config)
	self.HeldModel = nil
	self.conns = {}
	return self
end

function ThrowableClient:Equip()
	if self.Equipped then return end
	self.Equipped = true
	self:createHeldModel()
	self.conns.InputBegan = UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.Holding = true
			self.HoldStartTime = os.clock()
			self.TrajectoryPreview:Show()
		end
	end)
	self.conns.InputEnded = UserInputService.InputEnded:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Holding and self.Equipped then
			self:throw()
			self.Holding = false
			self.ChargePower = 0
			self.TrajectoryPreview:Hide()
		end
	end)
	self.conns.RenderStepped = RunService.RenderStepped:Connect(function(deltaTime)
		self:update(deltaTime)
	end)
	self:onEquip()
end

function ThrowableClient:Unequip()
	if not self.Equipped then return end
	self.Equipped = false
	if self.HeldModel then
		self.HeldModel:Destroy()
		self.HeldModel = nil
	end
	self.TrajectoryPreview:Hide()
	for _, connection in self.conns do
		connection:Disconnect()
	end
	self.conns = {}
	self:onUnequip()
end

function ThrowableClient:update(_deltaTime: number)
	if not self.Equipped then return end
	self:updateHeldModelPosition()
	if self.Holding then
		local holdTime = os.clock() - self.HoldStartTime
		self.ChargePower = math.clamp(holdTime / self.MaxChargeTime, 0.1, 1)
		local origin, direction = self:getThrowOriginAndDirection()
		self.TrajectoryPreview:Update(origin, direction, self.ChargePower)
		self:onCharging(self.ChargePower)
	end
end

function ThrowableClient:updateHeldModelPosition()
	if not self.HeldModel or not self.HeldModel.Parent then return end
	local character = LocalPlayer.Character
	if not character then return end
	local rightArm = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not rightArm then return end
	if self.HeldModel:IsA("Model") and self.HeldModel.PrimaryPart then
		self.HeldModel:PivotTo(rightArm.CFrame * CFrame.new(0, -1, 0))
	elseif self.HeldModel:IsA("BasePart") then
		self.HeldModel.CFrame = rightArm.CFrame * CFrame.new(0, -1, 0)
	end
end

function ThrowableClient:getThrowOriginAndDirection(): (Vector3, Vector3)
	local character = LocalPlayer.Character
	if not character then return Camera.CFrame.Position, Camera.CFrame.LookVector end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return Camera.CFrame.Position, Camera.CFrame.LookVector end
	-- Origin from camera or hand
	local origin = Camera.CFrame.Position
	-- Direction from camera look vector
	local direction = Camera.CFrame.LookVector
	return origin, direction
end

-- Throw projectile
function ThrowableClient:throw()
	local _origin, direction = self:getThrowOriginAndDirection()
	local holdTime = os.clock() - self.HoldStartTime
	local throwData = {
		direction = direction,
		holdTime = holdTime,
		uid = self.uid
	}
	self.RemoteEvent:FireServer(throwData)
	if self.HeldModel then
		self.HeldModel:Destroy()
		self.HeldModel = nil
		task.delay(0.5, function()
			if self.Equipped then
				self:createHeldModel()
			end
		end)
	end
	self:onThrow(throwData)
end

function ThrowableClient:onEquip()
	
end

function ThrowableClient:onUnequip()
	
end

function ThrowableClient:onCharging(_power)
	
end

function ThrowableClient:onThrow(_throwData)
	
end

function ThrowableClient:createHeldModel()
	if self.HeldModel then
		self.HeldModel:Destroy()
		self.HeldModel = nil
	end
	if self.Config.ProjectileModel then
		self.HeldModel = self.Config.ProjectileModel:Clone()
		self.HeldModel.Parent = Camera
		self:updateHeldModelPosition()
	end
end

function ThrowableClient:Destroy()
	self:Unequip()
	if self.TrajectoryPreview then
		self.TrajectoryPreview:Destroy()
		self.TrajectoryPreview = nil
	end
end

return ThrowableClient