local ServerStorage = game:GetService("ServerStorage")
local folder = ServerStorage:FindFirstChild("models"):FindFirstChild("tools")

local Backpack = {
	debugOn = false,
	autoEquip = false,
	stackingEnabled = true, 
}

local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

local function getItemTemplate(templateName:string, type:number?)
	if not templateName then return nil end
	local template = folder:FindFirstChild(tostring(type)):FindFirstChild(templateName)
	if not template then
		warn("Item template not found:", templateName)
		return nil
	end
	return template
end

local function cloneTool(templateName:string, type:number?)
	local template = getItemTemplate(templateName, type)
	if not template then return nil end
	if not template:IsA("Tool") then
		if Backpack.debugOn then
			warn("Template is not a Tool:", templateName)
		end
		return nil
	end
	return template:Clone()
end

-- Get or create quantity value for a tool
local function getOrCreateQuantity(tool: Tool)
	local quantityValue = tool:FindFirstChild("Quantity")
	if not quantityValue then
		quantityValue = Instance.new("IntValue")
		quantityValue.Name = "Quantity"
		quantityValue.Value = 1
		quantityValue.Parent = tool
	end
	return quantityValue
end

local function setToolInfo(tool: Tool, itemId: number?, itemType: number?, player: Player)
	if not tool or not tool:IsA("Tool") then
		return
	end
	if itemId == nil then
		return
	end
	tool:SetAttribute("id", itemId)
	if itemType then
		tool:SetAttribute("type", itemType)
	end
	local uid = player.UserId .. "_" .. itemId .. "_" .. os.clock()
	tool:SetAttribute("uid", uid)
end

-- Find existing tool in player's inventory (backpack or equipped)
local function findExistingTool(player: Player, itemName: string)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		local tool = backpack:FindFirstChild(itemName)
		if tool and tool:IsA("Tool") then
			return tool
		end
	end
	if player.Character then
		local equippedTool = player.Character:FindFirstChild(itemName)
		if equippedTool and equippedTool:IsA("Tool") then
			return equippedTool
		end
	end
	return nil
end

local function giveToolToPlayer(player:Player, tool:Tool)
	if not tool or not tool:IsA("Tool") then
		if Backpack.debugOn then
			warn("Invalid tool provided:", tool)
		end
		return false
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then
		if Backpack.debugOn then
			warn("Backpack not found for player:", player.Name)
		end
		return false
	end
	tool.Parent = backpack
	if Backpack.autoEquip then
		local character = player.Character
		if not character then
			if Backpack.debugOn then
				warn("Player character not found for auto-equip:", player.Name)
			end
			return true
		end
		character:WaitForChild("Humanoid"):EquipTool(tool)
	end
	return true
end

-- Give an item to a player
-- Returns: success (boolean), tools (array of Tool instances)
function Backpack:giveItem(player: Player, itemName: string, quantity: number, itemId: number?, itemType: number?)
	quantity = quantity or 1
	if not player or not player:IsA("Player") or not player.Character then
		return false, {}
	end
	if quantity < 1 or quantity > 999 then
		return false, {}
	end
	if Backpack.debugOn then
		print("Giving item:", itemName, "x", quantity, "to", player.Name)
	end
	local template = getItemTemplate(itemName, itemType)
	if not template then
		return false, {}
	end
	-- If stacking disabled or no existing tool, create new tool(s)
	if self.stackingEnabled then
		-- Check if stacking is enabled and player already has this tool
		local existingTool = findExistingTool(player, itemName)
		if existingTool then
			local quantityValue = getOrCreateQuantity(existingTool)
			quantityValue.Value = quantityValue.Value + quantity
			setToolInfo(existingTool, itemId, itemType, player)
			if Backpack.debugOn then
				print("Stacked", quantity, "to existing", itemName, "(Total:", quantityValue.Value, ")")
			end
			return true, {existingTool}
		end
		-- Create one tool with the full quantity
		local tool = cloneTool(itemName, itemType)
		if not tool then
			warn("Failed to clone tool:", itemName)
			return false, {}
		end
		
		local quantityValue = getOrCreateQuantity(tool)
		quantityValue.Value = quantity
		setToolInfo(tool, itemId, itemType, player)
		local success = giveToolToPlayer(player, tool)
		if not success then
			warn("Failed to give tool to player")
			tool:Destroy()
			return false, {}
		end
		return true, {tool}
	else
		-- Create multiple tools (no stacking)
		local givenTools = {}
		for _i = 1, quantity do
			local tool = cloneTool(itemName, itemType)
			if tool then
				setToolInfo(tool, itemId, itemType, player)
				local success = giveToolToPlayer(player, tool)
				if not success then
					warn("Failed to give tool to player")
					-- Cleanup previously given tools on failure
					for _, t in ipairs(givenTools) do
						t:Destroy()
					end
					return false, {}
				end
				table.insert(givenTools, tool)
			else
				warn("Failed to clone tool:", itemName)
				-- Cleanup previously given tools on failure
				for _, t in ipairs(givenTools) do
					t:Destroy()
				end
				return false, {}
			end
		end
		
		return true, givenTools
	end
end

function Backpack:removeItem(player: Player, itemName: string, quantity: number)
	quantity = quantity or 1
	if not player or not player:IsA("Player") or not player.Character then
		return false
	end
	if quantity < 1 or quantity > 999 then
		return false
	end
	-- Check if player has enough items first
	if not self:hasItem(player, itemName, quantity) then
		if Backpack.debugOn then
			warn("Player doesn't have enough items to remove:", itemName, "x", quantity)
		end
		return false
	end
	
	if self.stackingEnabled then
		-- Handle stacked removal
		local existingTool = findExistingTool(player, itemName)
		if existingTool then
			local quantityValue = existingTool:FindFirstChild("Quantity")
			if quantityValue and quantityValue:IsA("IntValue") then
				quantityValue.Value = quantityValue.Value - quantity
				
				if quantityValue.Value <= 0 then
					existingTool:Destroy()
				end
				if Backpack.debugOn then
					print("Removed", quantity, "from", itemName, "stack")
				end
				return true
			else
				-- No quantity value, just destroy the tool
				existingTool:Destroy()
				return true
			end
		end
		return false
	else
		-- Handle non-stacked removal
		local backpack = player:FindFirstChildOfClass("Backpack")
		local removed = 0
		if backpack then
			for _, tool in ipairs(backpack:GetChildren()) do
				if tool:IsA("Tool") and tool.Name == itemName and removed < quantity then
					tool:Destroy()
					removed = removed + 1
				end
			end
		end
		-- Remove from equipped if needed
		if removed < quantity then
			local equippedTool = player.Character:FindFirstChildOfClass("Tool")
			if equippedTool and equippedTool.Name == itemName then
				equippedTool:Destroy()
				removed = removed + 1
			end
		end
		if Backpack.debugOn then
			print("Removed item:", itemName, "x", removed, "from", player.Name)
		end
		return removed == quantity
	end
end

function Backpack:hasItem(player: Player, itemName: string, quantity: number?)
	if not player or not player:IsA("Player") or not player.Character then
		return false
	end
	
	if self.stackingEnabled then
		-- Check stacked quantity
		local existingTool = findExistingTool(player, itemName)
		if not existingTool then
			return false
		end
		
		local quantityValue = existingTool:FindFirstChild("Quantity")
		local count = quantityValue and quantityValue:IsA("IntValue") and quantityValue.Value or 1
		
		if Backpack.debugOn and quantity then
			print("Checking for item:", itemName, "x", quantity, "in", player.Name .. "'s backpack. Found:", count)
		end
		
		if not quantity then
			return count > 0
		else
			return count >= quantity
		end
	else
		-- Count individual tools
		local backpack = player:FindFirstChildOfClass("Backpack")
		local count = 0
		if backpack then
			for _, tool in ipairs(backpack:GetChildren()) do
				if tool:IsA("Tool") and tool.Name == itemName then
					count = count + 1
				end
			end
		end
		local equippedTool = player.Character:FindFirstChildOfClass("Tool")
		if equippedTool and equippedTool.Name == itemName then
			count = count + 1
		end
		
		if Backpack.debugOn and quantity then
			print("Checking for item:", itemName, "x", quantity, "in", player.Name .. "'s backpack. Found:", count)
		end
		
		if not quantity then
			return count > 0
		else
			return count >= quantity
		end
	end
end

function Backpack:clearAllItems(player: Player)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		backpack:ClearAllChildren()
	end
	if player.Character then
		local equippedTool = player.Character:FindFirstChildOfClass("Tool")
		if equippedTool then
			equippedTool:Destroy()
		end
	end
	if Backpack.debugOn then
		print("Cleared all items for", player.Name)
	end
	return true
end

-- Get the quantity of a specific item the player has
-- Returns the total quantity (works with both stacked and non-stacked items)
function Backpack:getItemQuantity(player: Player, itemName: string)
	if not player or not player:IsA("Player") or not player.Character then
		return 0
	end
	if self.stackingEnabled then
		local existingTool = findExistingTool(player, itemName)
		if not existingTool then
			return 0
		end
		local quantityValue = existingTool:FindFirstChild("Quantity")
		return quantityValue and quantityValue:IsA("IntValue") and quantityValue.Value or 1
	else
		-- Count individual tools
		local backpack = player:FindFirstChildOfClass("Backpack")
		local count = 0
		if backpack then
			for _, tool in ipairs(backpack:GetChildren()) do
				if tool:IsA("Tool") and tool.Name == itemName then
					count = count + 1
				end
			end
		end
		local equippedTool = player.Character:FindFirstChildOfClass("Tool")
		if equippedTool and equippedTool.Name == itemName then
			count = count + 1
		end
		return count
	end
end

-- Get the tool instance for a specific item
-- Returns the tool if found, nil otherwise
function Backpack:getTool(player: Player, itemName: string)
	if not player or not player:IsA("Player") or not player.Character then
		return nil
	end
	return findExistingTool(player, itemName)
end

return Backpack