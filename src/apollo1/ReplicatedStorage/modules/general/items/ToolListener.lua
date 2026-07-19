local ToolListener = {}
ToolListener.__index = ToolListener

local function getItemId(tool: Tool):number?
    if not tool or not tool:IsA("Tool") then
        return nil
    end
    local itemId = tool:GetAttribute("id")
    if type(itemId) == "string" then
        itemId = tonumber(itemId)
    end
    if type(itemId) ~= "number" then
        return nil
    end
    return itemId
end

local function getItemInfo(tool: Tool):(number?, number?)
    if not tool or not tool:IsA("Tool") then
        return nil
    end
    local itemId = tool:GetAttribute("id")
    local itemType = tool:GetAttribute("type")
    if type(itemId) == "string" then
        itemId = tonumber(itemId)
    end
    if type(itemType) == "string" then
        itemType = tonumber(itemType)
    end
    if not itemId then
        return nil
    end
    return itemId, itemType
end

local function getQuantity(tool: Tool):IntValue?
    if not tool or not tool:IsA("Tool") then
        return nil
    end
	local quantityValue = tool:FindFirstChild("Quantity")
	if not quantityValue or not quantityValue:IsA("IntValue") then
		return nil
	end
	return quantityValue
end

function ToolListener.new(player:Player, toolList, backpackChangedEvent:BindableEvent)
    local self = setmetatable({}, ToolListener)
    self.conns = {}
    self.loaded = false
    self.childConns = {}
    self.player = player
    self.items = {}
    self.tools = {}
    self.toolList = toolList
    self.backpackChangedEvent = backpackChangedEvent
    self:load(player)
    return self
end

function ToolListener:load(player:Player)
    if self.loaded then 
        self:unload()
    end
    if not player then return end
    local Backpack = player:WaitForChild("Backpack", 10)
    if not Backpack then return end
    self.player = player
    local conn = Backpack.ChildAdded:Connect(function(child: Tool)
        --new tool added to Backpack, check if it has quantity and listen for changes
        local quantity = getQuantity(child)
        if quantity then
            self:connectQuantityListener(child,quantity)
            self:handleItemAdded(child)
        end
    end)
    table.insert(self.conns, conn)

    local conn2 = Backpack.ChildRemoved:Connect(function(child: Tool)
        --tool removed from Backpack, stop listening for changes
        local quantity = getQuantity(child)
        if quantity then
            self:disconnectQuantityListener(child, quantity)
            self:handleItemRemoved(child)
        end
    end)
    table.insert(self.conns, conn2)

    local backpackItems = Backpack:GetChildren()
    self:connectQuantityListenerInit(backpackItems)
    self.loaded = true
end

function ToolListener:unload()
    for _, conn in pairs(self.conns) do
        if conn then
            conn:Disconnect()
        end
    end
    self.conns = {}
    for _, conn in pairs(self.childConns) do
        if conn then
            conn:Disconnect()
        end
    end
    self.childConns = {}
    self.loaded = false
end

function ToolListener:onItemsChange(tool: Tool, quantity: number)
    if not tool or not tool:IsA("Tool") then
        return
    end
    local itemId = getItemId(tool)
    if itemId == nil then
        return
    end
    self.items[itemId] = quantity
end

function ToolListener:handleItemValueChange(tool: Tool, quantity: IntValue?, forcedAmount: number?)
    if self.debugOn then
        print("Nothing here yet", tool, "quantity", quantity, "forcedAmount", forcedAmount)
    end
end

function ToolListener:handleItemAdded(tool: Tool)
    if self.tools[tool]  then
        return
    end
    local itemId, itemType = getItemInfo(tool)
    if not itemId or not itemType then
        return
    end
    local module = self.toolList[itemType] 
    if not module then
        return
    end
    local moduleSuccess, moduleResult = pcall(function()
            return module.new(tool, itemId)
    end)
    if moduleSuccess and moduleResult then
        if not self.tools[tool] then
            self.tools[tool] = {}
        end
        self.tools[tool] = moduleResult
    end
end

function ToolListener:handleItemRemoved(tool: Tool)
    if not self.tools[tool] then return end
    local module = self.tools[tool]
    if module and module.unload then
        module:unload()
    end
    self.tools[tool] = nil
end

function ToolListener:connectQuantityListener(tool: Tool, quantity: IntValue, init:boolean?)
    if not tool or not tool:IsA("Tool") then
        return
    end
    if not quantity or not quantity:IsA("IntValue") then
        return
    end
    local conn = quantity.Changed:Connect(function()
        self:onItemsChange(tool, quantity.Value)
    end)
    if not self.childConns[tool] then
        self.childConns[tool] = conn
    end
    self:onItemsChange(tool, quantity.Value)
    if init then 
        return 
    end
    self.backpackChangedEvent:Fire(self.items)
end

function ToolListener:disconnectQuantityListener(tool: Tool, quantity: IntValue)
    if not tool or not tool:IsA("Tool") then
        return
    end
    if not quantity or not quantity:IsA("IntValue") then
        return
    end
    if self.childConns[tool] then
        self.childConns[tool]:Disconnect()
        self.childConns[tool] = nil
    end
    self:onItemsChange(tool, 0)
    self.backpackChangedEvent:Fire(self.items)
end

function ToolListener:connectQuantityListenerInit(tools: {Instance})
    for _, tool in ipairs(tools) do
        if not tool or not tool:IsA("Tool") then
            continue
        end
        local quantity = getQuantity(tool)
        if not quantity then
            continue
        end
        self:connectQuantityListener(tool, quantity, true)
        self:handleItemAdded(tool)
    end
    self.backpackChangedEvent:Fire(self.items)
end

return ToolListener