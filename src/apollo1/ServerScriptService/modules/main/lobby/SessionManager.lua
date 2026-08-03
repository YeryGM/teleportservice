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
		local ok, result = pcall(function()
			local options = Instance.new("TeleportOptions")
			options:SetTeleportData(teleportData)
			return TeleportService:TeleportAsync(placeId, playerList, options)
		end)

		if ok then
			if result and result.Status ~= Enum.TeleportStatus.TeleportSuccess then
				warn("[SessionManager] TeleportAsync status: " .. tostring(result.Status)
					.. " (attempt " .. attempt .. "/" .. MAX_RETRIES .. ")")
				if attempt < MAX_RETRIES then
					task.wait(RETRY_DELAY)
				end
				continue
			end

			if debugOn then
				print("[SessionManager] TeleportAsync succeeded")
			end
			return { success = true }
		end

		warn("[SessionManager] TeleportAsync exception (attempt " .. attempt .. "/" .. MAX_RETRIES .. "): " .. tostring(result))

		if attempt < MAX_RETRIES then
			task.wait(RETRY_DELAY)
		end
	end

	return { success = false, error = "Teleport failed after " .. MAX_RETRIES .. " attempts" }
end

return SessionManager
