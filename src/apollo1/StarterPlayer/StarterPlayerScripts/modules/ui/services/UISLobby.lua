local debugOn = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LobbyActions = require(script.Parent.Parent.store.lobby.LobbyActions)

local lobbyEvents = ReplicatedStorage:WaitForChild("events"):WaitForChild("general"):WaitForChild("lobby")
local OpenLobbyUI: RemoteEvent = lobbyEvents:WaitForChild("OpenLobbyUI")
local CloseLobbyUI: RemoteEvent = lobbyEvents:WaitForChild("CloseLobbyUI")
local SubmitLobbyConfig: RemoteEvent = lobbyEvents:WaitForChild("SubmitLobbyConfig")
local CancelLobby: RemoteEvent = lobbyEvents:WaitForChild("CancelLobby")

local UISLobby = {}
local connections = {}

function UISLobby.init()
	local openConn = OpenLobbyUI.OnClientEvent:Connect(function(data)
		if debugOn then
			local count = data and data.chapters and #data.chapters or 0
			print("[UISLobby] OpenLobbyUI recibido -> " .. tostring(count) .. " capitulos disponibles")
		end

		if data and data.chapters then
			LobbyActions.setChapters(data.chapters)
		end
		LobbyActions.openLobby()
	end)

	local closeConn = CloseLobbyUI.OnClientEvent:Connect(function()
		if debugOn then
			print("[UISLobby] CloseLobbyUI recibido -> cerrando lobby")
		end
		LobbyActions.closeLobby()
	end)

	table.insert(connections, openConn)
	table.insert(connections, closeConn)

	if debugOn then
		print("[UISLobby] Listeners inicializados (OpenLobbyUI, CloseLobbyUI)")
	end
end

function UISLobby.destroy()
	for _, conn in ipairs(connections) do
		if conn and conn.Connected then
			conn:Disconnect()
		end
	end
	connections = {}

	if debugOn then
		print("[UISLobby] Connections destruidas")
	end
end

function UISLobby.submitConfig(chapter: string, difficulty: number)
	if debugOn then
		print("[UISLobby] submitConfig -> chapter: " .. chapter .. ", difficulty: " .. tostring(difficulty))
	end
	SubmitLobbyConfig:FireServer({ chapter = chapter, difficulty = difficulty })
end

function UISLobby.cancel()
	if debugOn then
		print("[UISLobby] cancel -> CancelLobby:FireServer()")
	end
	CancelLobby:FireServer()
end

return UISLobby
