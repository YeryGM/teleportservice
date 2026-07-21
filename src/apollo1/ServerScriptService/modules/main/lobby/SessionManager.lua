local DEBUG_MODE = true

local MemoryStoreService = game:GetService("MemoryStoreService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local SESSION_EXPIRY = 600
local MAX_RETRIES = 2
local RETRY_DELAY = 1

local SessionManager = {}

function SessionManager.CreateAndTeleport(playerList: { Player }, placeId: number, params: { chapter: string, difficulty: number, size: number }): { success: boolean, error: string? }
	if #playerList == 0 then
		return { success = false, error = "No players provided" }
	end

	local sessionId = HttpService:GenerateGUID(false)
	if DEBUG_MODE then
		print("[SessionManager] SessionID: " .. sessionId)
	end

	local playerNames = {}
	for _, player in ipairs(playerList) do
		table.insert(playerNames, player.Name)
	end

	local sortedMap = MemoryStoreService:GetSortedMap("LobbySessions")
	local okStore, errStore = pcall(function()
		sortedMap:SetAsync(sessionId, {
			chapter = params.chapter,
			difficulty = params.difficulty,
			size = params.size,
			players = playerNames,
		}, SESSION_EXPIRY)
	end)

	if not okStore then
		warn("[SessionManager] MemoryStore failed -> " .. tostring(errStore))
	else
		if DEBUG_MODE then
			print("[SessionManager] Session saved (expires in " .. tostring(SESSION_EXPIRY) .. "s)")
		end
	end

	local teleportData = {
		session = sessionId,
		chapter = params.chapter,
		difficulty = params.difficulty,
		size = params.size,
	}

	for attempt = 1, MAX_RETRIES do
		local okTeleport, errTeleport = pcall(function()
			TeleportService:TeleportAsync(placeId, playerList, teleportData)
		end)

		if okTeleport then
			if DEBUG_MODE then
				print("[SessionManager] TeleportAsync succeeded")
			end
			return { success = true }
		end

		warn("[SessionManager] TeleportAsync failed (attempt " .. attempt .. "/" .. MAX_RETRIES .. ") -> " .. tostring(errTeleport))

		if attempt < MAX_RETRIES then
			task.wait(RETRY_DELAY)
		end
	end

	return { success = false, error = "Teleport failed after " .. MAX_RETRIES .. " attempts" }
end

return SessionManager
