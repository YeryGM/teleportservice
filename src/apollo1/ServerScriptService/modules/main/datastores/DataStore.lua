--!strict

local DatastoreService = game:GetService("DataStoreService")

type DatastoreConfig = {
	AutoSave: boolean?,
	SaveInterval: number?,
	RetryAttempts: number?,
	RetryDelay: number?,
	DefaultData: { [string]: any }?,
	UseScopes: boolean?,
	ScopeSeparator: string?,
}

type ResolvedConfig = {
	AutoSave: boolean,
	SaveInterval: number,
	RetryAttempts: number,
	RetryDelay: number,
	DefaultData: { [string]: any },
	UseScopes: boolean,
	ScopeSeparator: string,
}

type DatastoreObject = any

local DatastoreModule = {} :: any
DatastoreModule.__index = DatastoreModule

const DEFAULT_CONFIG: ResolvedConfig = {
	AutoSave = true,
	SaveInterval = 240,
	RetryAttempts = 5,
	RetryDelay = 0.5,
	DefaultData = {},
	UseScopes = true, 
	ScopeSeparator = "/" 
}

local function deepCopy(original: any): any
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

local function mergeTables(base: any, override: any): any
	local result = deepCopy(base)
	for k, v in pairs(override) do
		if type(v) == "table" and type(result[k]) == "table" then
			result[k] = mergeTables(result[k], v)
		else
			result[k] = v
		end
	end
	return result
end

function DatastoreModule.new(datastoreName: string, config: DatastoreConfig?, parentStore: DatastoreObject?, scopePath: string?): DatastoreObject
	local self = setmetatable({}, DatastoreModule) :: DatastoreObject
	self.Name = datastoreName 
	self.Config = mergeTables(DEFAULT_CONFIG, config or {}) :: ResolvedConfig
	self.ParentStore = parentStore 
	self.ScopePath = scopePath or "" 
	-- Only create actual datastore if not using parent's scope
	if self.Config.UseScopes and parentStore then
		self.Datastore = parentStore.Datastore -- Share parent's datastore
		self.IsScoped = true
	else
		self.Datastore = DatastoreService:GetDataStore(self.Name)
		self.IsScoped = false
	end
	self.Cache = {}
	self.NestedStores = {}
	self.Metadata = {}
	self.IsSaving = false
	self.AutoSaveThread = nil
	self.debugOn = false
	-- Start autosave if enabled and not a nested scoped store
	if self.Config.AutoSave and not self.IsScoped then
		self:_StartAutoSave()
	end
	
	return self
end

function DatastoreModule:_BuildKey(key: string): string
	-- If this is a scoped store, prefix the key with the scope path
	if self.IsScoped and self.ScopePath ~= "" then
		return self.ScopePath .. self.Config.ScopeSeparator .. key
	end
	return key
end

function DatastoreModule:_ParseKey(fullKey: string): string
	-- Remove scope prefix if present
	if self.IsScoped and self.ScopePath ~= "" then
		local prefix = self.ScopePath .. self.Config.ScopeSeparator
		if fullKey:sub(1, #prefix) == prefix then
			return fullKey:sub(#prefix + 1)
		end
	end
	return fullKey
end

function DatastoreModule:CreateNestedStore(name: string, config: DatastoreConfig?): DatastoreObject
	if self.NestedStores[name] then
		warn("Nested store already exists: " .. name)
		return self.NestedStores[name]
	end
	-- Merge config with parent's config
	local nestedConfig = mergeTables(self.Config, config or {})
	local nestedStore
	if nestedConfig.UseScopes then
		-- Use scoped approach - share the same datastore
		local scopePath = self.ScopePath == "" 
			and name 
			or (self.ScopePath .. self.Config.ScopeSeparator .. name)
		nestedStore = DatastoreModule.new(
			self.Name, -- Keep same datastore name
			nestedConfig,
			self.ParentStore or self, -- Root parent
			scopePath
		)
	else
		-- Use separate datastore approach
		local fullName = self.Name .. "_" .. name
		nestedStore = DatastoreModule.new(fullName, nestedConfig)
	end
	self.NestedStores[name] = nestedStore
	return nestedStore
end

function DatastoreModule:GetNestedStore(name: string): DatastoreObject?
	return self.NestedStores[name]
end

function DatastoreModule:GetAllNestedStores()
	return self.NestedStores
end

function DatastoreModule:GetFullPath()
	return self.IsScoped and self.ScopePath or self.Name
end

function DatastoreModule:SetMetadata(key: string, value: any)
	self.Metadata[key] = value
end

function DatastoreModule:GetMetadata(key: string): any
	return self.Metadata[key]
end

function DatastoreModule:AddTag(tag: string)
	if not self.Metadata.Tags then
		self.Metadata.Tags = {}
	end
	table.insert(self.Metadata.Tags, tag)
end

function DatastoreModule:HasTag(tag: string): boolean
	if not self.Metadata.Tags then return false end
	for _, t in ipairs(self.Metadata.Tags) do
		if t == tag then return true end
	end
	return false
end

function DatastoreModule:_StartAutoSave()
	if self.AutoSaveThread then
		return -- Already running
	end
	
	self.AutoSaveThread = task.spawn(function()
		while self.AutoSaveThread do
			task.wait(self.Config.SaveInterval)
			if self.AutoSaveThread and not self.IsSaving then
				self:SaveAllCached()
			end
		end
	end)
end

function DatastoreModule:StopAutoSave()
	if self.AutoSaveThread then
		local thread = self.AutoSaveThread
		self.AutoSaveThread = nil
		task.cancel(thread)
		if self.debugOn then
			print(self, "AutoSave stopped")
		end
	end
end

function DatastoreModule:CacheData(key: string, data: any): boolean
	local fullKey = self:_BuildKey(key)
	if data == nil then
		if self.debugOn then
			warn(self, "CacheData rejected nil data for: " .. fullKey)
		end
		return false
	end
	self.Cache[fullKey] = data
	if self.debugOn then
		print(self, "Data cached (not saved yet): " .. fullKey)
	end
	return true
end

function DatastoreModule:UpdateCachedData(key: string, updateFunction: (data: any) -> (any?, string?)): (boolean, string?)
	local data = self:LoadData(key)
	local newData, err = updateFunction(deepCopy(data))
	if newData == nil then
		return false, err or "Update rejected"
	end
	return self:CacheData(key, newData)
end

function DatastoreModule:LoadData(key: string, defaultData: { [string]: any }?): ({ [string]: any }, boolean)
	local fullKey = self:_BuildKey(key)
	-- Check cache first
	if self.Cache[fullKey] then
		return self.Cache[fullKey], true
	end
	-- Attempt to load from datastore with retries
	for attempt = 1, self.Config.RetryAttempts do
		local success, result = pcall(function()
			return self.Datastore:GetAsync(fullKey)
		end)
		if success then
			local data = result or defaultData or deepCopy(self.Config.DefaultData)
			self.Cache[fullKey] = data
			return data, true
		else
			warn(self, string.format("Load attempt %d/%d failed for %s: %s", 
				attempt, self.Config.RetryAttempts, fullKey, tostring(result)))
			
			if attempt < self.Config.RetryAttempts then
				task.wait(self.Config.RetryDelay)
			end
		end
	end
	warn(self, "Failed to load data for: " .. fullKey)
	return defaultData or deepCopy(self.Config.DefaultData), false
end

function DatastoreModule:SaveData(key: string, data: any): boolean
	local fullKey = self:_BuildKey(key)
	-- Update cache
	self.Cache[fullKey] = data
	-- Attempt to save to datastore with retries
	for attempt = 1, self.Config.RetryAttempts do
		if not data then
			warn(self, "No data provided to save for: " .. fullKey)
			return false
		end
		local success, result = pcall(function()
			self.Datastore:SetAsync(fullKey, data)
		end)
		
		if success then
			if self.debugOn then
				print(self, "Data saved successfully for: " .. fullKey)
			end
			return true
		else
			if self.debugOn then
				warn(string.format("Save attempt %d/%d failed for %s: %s", 
					attempt, self.Config.RetryAttempts, fullKey, tostring(result)))
			end
			if attempt < self.Config.RetryAttempts then
				task.wait(self.Config.RetryDelay)
			end
		end
	end
	if self.debugOn then
		warn(self, "Failed to save data for: " .. fullKey)
	end
	return false
end

function DatastoreModule:UpdateData(key: string, updateFunction: (data: any) -> (any?, string?)): (boolean, string?)
	local fullKey = self:_BuildKey(key)
	local updateError: string? = nil
	local lastError: string? = nil
	local updatedData: any = nil

	for attempt = 1, self.Config.RetryAttempts do
		local success, result = pcall(function()
			return self.Datastore:UpdateAsync(fullKey, function(oldData)
				local baseData = oldData or deepCopy(self.Config.DefaultData)
				local workingCopy = deepCopy(baseData)
				local newData, err = updateFunction(workingCopy)
				if newData == nil then
					updateError = err or "Update rejected"
					return baseData
				end
				return newData
			end)
		end)

		if success then
			updatedData = result
			break
		else
			lastError = tostring(result)
			if self.debugOn then
				warn(string.format("Update attempt %d/%d failed for %s: %s",
					attempt, self.Config.RetryAttempts, fullKey, tostring(result)))
			end
			if attempt < self.Config.RetryAttempts then
				task.wait(self.Config.RetryDelay)
			end
		end
	end

	if updatedData ~= nil then
		self.Cache[fullKey] = updatedData
	end

	if updateError then
		return false, updateError
	end

	if updatedData == nil then
		return false, lastError or "UpdateAsync failed"
	end

	return true
end

function DatastoreModule:DeleteData(key: string): boolean
	local fullKey = self:_BuildKey(key)
	self.Cache[fullKey] = nil
	for attempt = 1, self.Config.RetryAttempts do
		local success, result = pcall(function()
			self.Datastore:RemoveAsync(fullKey)
		end)
		if success then
			if self.debugOn then
				print(self, "Deleted from datastore: " .. fullKey)
			end
			return true
		end
		if self.debugOn then
			warn(self, string.format("Delete attempt %d/%d failed for %s: %s",
				attempt, self.Config.RetryAttempts, fullKey, tostring(result)))
		end
		if attempt < self.Config.RetryAttempts then
			task.wait(self.Config.RetryDelay)
		end
	end
	return false
end

function DatastoreModule:GetCachedData(key: string): any
	local fullKey = self:_BuildKey(key)
	return self.Cache[fullKey]
end

function DatastoreModule:ClearCache(key: string?)
	if key then
		local fullKey = self:_BuildKey(key)
		table.clear(self.Cache[fullKey])
		self.Cache[fullKey] = nil
	else
		table.clear(self.Cache)
		self.Cache = {}
	end
	if self.debugOn then
		print(self, "Cache cleared" .. (key and ": " .. key or ""))
	end
end

function DatastoreModule:SaveAllCached(): boolean
	if self.IsSaving then
		warn(self, "Already saving, skipping duplicate save")
		return false
	end
	
	self.IsSaving = true
	local success = true
	local savedCount = 0
	
	for fullKey, data in pairs(self.Cache) do
		local localKey = self:_ParseKey(fullKey)
		if not self:SaveData(localKey, data) then
			success = false
		else
			savedCount = savedCount + 1
		end
		-- Small delay between saves to respect rate limits
		if savedCount % 10 == 0 then
			task.wait(0.1)
		end
	end
	
	if self.debugOn then
		print(self, string.format("Saved %d cached entries", savedCount))
	end
	
	self.IsSaving = false
	return success
end

function DatastoreModule:GetInfo(): { [string]: any }
	return {
		Name = self.Name,
		IsScoped = self.IsScoped,
		ScopePath = self.ScopePath,
		CachedKeys = self:GetCachedKeys(),
		NestedStoreCount = self:GetNestedStoreCount(),
		AutoSaveEnabled = self.Config.AutoSave,
		AutoSaveRunning = self.AutoSaveThread ~= nil,
		IsSaving = self.IsSaving,
		Metadata = self.Metadata,
		Config = self.Config
	}
end

function DatastoreModule:GetCachedKeys(): { string }
	local keys = {}
	for key in pairs(self.Cache) do
		table.insert(keys, key)
	end
	return keys
end

function DatastoreModule:GetNestedStoreCount(): number
	local count = 0
	for _ in pairs(self.NestedStores) do
		count = count + 1
	end
	return count
end

function DatastoreModule:unload()
	self:StopAutoSave()
	-- Save any remaining cached data before destroying
	if next(self.Cache) then
		self:SaveAllCached()
	end
	for _, store in pairs(self.NestedStores) do
		if store.unload then
			store:unload()
		end
	end
	self.Cache = {}
	self.NestedStores = {}
end

return DatastoreModule