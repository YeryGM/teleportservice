local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local getProductInfo = ReplicatedStorage.funcs.server.purchases.remote:WaitForChild("getProductInfo")

local VendingMachine = {
	debugOn = false,
	productIds = {},
	keys = {
		[Enum.KeyCode.W] = true,
		[Enum.KeyCode.A] = true,
		[Enum.KeyCode.S] = true,
		[Enum.KeyCode.D] = true
	}
}
VendingMachine.__index = VendingMachine

function VendingMachine.new(gui: ScreenGui, model: Model)
	assert(gui and gui:IsA("ScreenGui"), "gui must be a ScreenGui")
	assert(model and model:IsA("Model"), "model must be a Model")
	local self = setmetatable({}, VendingMachine)
	self.gui = gui
	self.model = model
	self.cameraPart = model:FindFirstChild("CameraPart") 
	self.conns = {}
	self.products = {}
	self.surfaces = {}
	self.surfaceParts = {}
	return self
end

function VendingMachine:load()
	self:setUpSurfaceParts()
	self:setUpSurfaceGuis()
	self:getProducts()
	self:setProductInfo()
	local conn4 = UserInputService.InputBegan:Connect(function(input)
		if  self.keys[input.KeyCode] then
			self:toggleDisplay(false)
		end
	end)
	table.insert(self.conns, conn4)
end

function VendingMachine:unload()
	for _, conn in pairs(self.conns) do
		conn:Disconnect()
	end
	self.conns = {}
end

function VendingMachine:getProducts()
    for _, id in pairs(self.productIds) do
        local product = getProductInfo:InvokeServer(id)
        if not product then
            if self.debugOn then
                warn(string.format("Failed to load product info for product ID %d", id))
            end
        end
        self.products[id] = product
    end
end

function VendingMachine:setProductInfo()
	for _, product in ipairs(self.model.products:GetChildren()) do
		local item = self.products[product.Name]
		local productFrame = self.surfaces[product.Name].gui:FindFirstChild("Frame")
		if not item then
			if self.debugOn then
				warn(string.format("No product data found for %s", product.Name))
			end
			continue
		end
		self:setProductFrame(item, productFrame, product.Name)
	end
end

function VendingMachine:setProductFrame(item, productFrame:Frame, itemId)
    local imageLabel = productFrame:FindFirstChild("ImageLabel")
    imageLabel.Image = item.ImageId
    local nameLabel = productFrame:FindFirstChild("NameLabel")
    nameLabel.Text = item.Name
    local priceFrame = productFrame:FindFirstChild("PriceFrame")
    local priceImage = priceFrame:FindFirstChild("PriceImage")
    if item.Type == "DP" then
        priceImage.Image = "rbxassetid://87654321" --robux icon
    else
        priceImage.Image = "rbxassetid://12345678" -- credits icon
    end
    local priceLabel = priceFrame:FindFirstChild("PriceLabel")
    priceLabel.Text = string.format("%d Credits", item.Price)
    
    local conn = priceFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:purchaseItem(item, {amount = 1})
        end
    end)
    
	local originalSize = productFrame.Size
	local worldModel = self.surfaces[itemId].worldModel
	local originalOrientation = worldModel:GetPivot()
	local rotationTween = nil

	local conn2 = productFrame.MouseEnter:Connect(function()
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local scaler = 1.2
		local scaleTween = TweenService:Create(productFrame, tweenInfo, {
			Size = UDim2.new(
				originalSize.X.Scale * scaler,
				originalSize.X.Offset * scaler,
				originalSize.Y.Scale * scaler,
				originalSize.Y.Offset * scaler
			)
		})
		scaleTween:Play()
		
		-- Start rotating the model
		local rotateInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
		rotationTween = TweenService:Create(worldModel, rotateInfo, {
			CFrame = worldModel.CFrame * CFrame.Angles(0, math.rad(360), 0)
		})
		rotationTween:Play()
	end)

	local conn3 = productFrame.MouseLeave:Connect(function()
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local scaleTween = TweenService:Create(productFrame, tweenInfo, {
			Size = originalSize
		})
		scaleTween:Play()
		
		-- Stop rotation and reset orientation
		if rotationTween then
			rotationTween:Cancel()
		end
		worldModel:PivotTo(originalOrientation)
	end)
	table.insert(self.conns, conn)
	table.insert(self.conns, conn2)
	table.insert(self.conns, conn3)		
end

function VendingMachine:setUpSurfaceParts()
	for _, surfacePart in ipairs(self.model.products:GetChildren()) do
		local itemModel = surfacePart:FindFirstChild("model")
		if not itemModel then
			if self.debugOn then
				warn(string.format("No model found for surface %s", surfacePart.Name))
			end
			continue
		end
		self.surfaceParts[surfacePart.Name] = {
			part = surfacePart,
			model = itemModel
		}
	end
end

function VendingMachine:setUpSurfaceGuis()
	for _, surfaceGui in ipairs(self.gui.surfaces:GetChildren()) do
		self.surfaces[surfaceGui.Name].gui = surfaceGui
		surfaceGui.Adornee = self.surfaceParts[surfaceGui.Name].part

		local viewportFrame = surfaceGui:FindFirstChild("ViewportFrame")
		if not viewportFrame or not viewportFrame:IsA("ViewportFrame") then 
			if self.debugOn then
				warn(string.format("No ViewportFrame found in surface GUI %s", surfaceGui.Name))
			end
			continue 
		end
		viewportFrame.Size = UDim2.fromScale(1, 1)
		viewportFrame.CurrentCamera = Workspace.CurrentCamera

		local worldModel = viewportFrame:FindFirstChild("WorldModel")
		if not worldModel then
			worldModel = Instance.new("WorldModel")
			worldModel.Name = "WorldModel"
			worldModel.Parent = viewportFrame
		end

		local clone = self.surfaceParts[surfaceGui.Name].model:Clone()
		clone.Parent = worldModel

		self.surfaces[surfaceGui.Name].worldModel = clone	
	end
end

function VendingMachine:toggleDisplay(value)
	if value == nil then
		value = not self.currentGui.Enabled
	end
	self.currentGui.Enabled = value
	if value then
		Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		Workspace.CurrentCamera.CFrame = self.cameraPart.CFrame
	else
		Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end

return VendingMachine