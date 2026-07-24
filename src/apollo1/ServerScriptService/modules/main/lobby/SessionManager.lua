local debugOn = true

local TeleportService = game:GetService("TeleportService")

local MAX_RETRIES = 2
local RETRY_DELAY = 1

local SessionManager = {}

function SessionManager.TeleportGroup(playerList: { Player }, placeId: number, teleportData: { session: string, chapter: string, difficulty: number, size: number }): { success: boolean, error: string? }
	if #playerList == 0 then
		return { success = false, error = "No players provided" }
	end

	for attempt = 1, MAX_RETRIES do
		local ok, err = pcall(function()
			TeleportService:TeleportAsync(placeId, playerList, teleportData)
		end)

		if ok then
			if debugOn then
				print("[SessionManager] TeleportAsync succeeded")
			end
			return { success = true }
		end

		warn("[SessionManager] TeleportAsync failed (attempt " .. attempt .. "/" .. MAX_RETRIES .. ") -> " .. tostring(err))

		if attempt < MAX_RETRIES then
			task.wait(RETRY_DELAY)
		end
	end

	return { success = false, error = "Teleport failed after " .. MAX_RETRIES .. " attempts" }
end

return SessionManager
