local debugOn = true

local MemoryStoreService = game:GetService("MemoryStoreService")

local SESSION_EXPIRY = 600
local MAP_NAME = "LobbySessions"

local MemoryStoreManager = {}

function MemoryStoreManager.SaveSession(sessionId: string, data: { chapter: string, difficulty: number, size: number, players: { string } }): boolean
	local sortedMap = MemoryStoreService:GetSortedMap(MAP_NAME)

	local ok, err = pcall(function()
		sortedMap:SetAsync(sessionId, data, SESSION_EXPIRY)
	end)

	if not ok then
		warn("[MemoryStoreManager] SaveSession failed -> " .. tostring(err))
		return false
	end

	if debugOn then
		print("[MemoryStoreManager] Session saved (expires in " .. tostring(SESSION_EXPIRY) .. "s)")
	end

	return true
end

return MemoryStoreManager
