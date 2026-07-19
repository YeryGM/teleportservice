local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

-- Evento bindable
local nextP = ReplicatedStorage:WaitForChild("events"):WaitForChild("server"):WaitForChild("general"):WaitForChild("bindable"):WaitForChild("next")

-- Estado de progreso de cada jugador
local playerProgress = {}

-- Obtener todas las partes con tag "checkp" y "camino"
local checkpoints = CollectionService:GetTagged("checkp")
local caminos = CollectionService:GetTagged("camino")

-- Función para obtener una parte "camino" por su id
local function getCaminoById(id)
	for _, camino in ipairs(caminos) do
		if camino:GetAttribute("id") == id then
			return camino
		end
	end
	return nil
end

-- Conectar el evento nextP
nextP.Event:Connect(function(player, id)
	-- Oculta el textlabel anterior si existe
	local prevCamino = getCaminoById(id - 1)
	if prevCamino then
		local billboard = prevCamino:FindFirstChildWhichIsA("BillboardGui")
		if billboard and billboard:FindFirstChildOfClass("TextLabel") then
			billboard:FindFirstChildOfClass("TextLabel").Visible = false
		end
	end

	-- Muestra el textlabel del camino actual
	local camino = getCaminoById(id)
	if camino then
		local billboard = camino:FindFirstChildWhichIsA("BillboardGui")
		if billboard and billboard:FindFirstChildOfClass("TextLabel") then
			billboard:FindFirstChildOfClass("TextLabel").Visible = true
		end
	end
end)

-- Función para cuando se toca un checkpoint
local function onCheckpointTouched(part, hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end

	local id = part:GetAttribute("id")
	if not id then return end

	-- Si el jugador no tiene progreso, empieza desde 0
	if not playerProgress[player] then
		playerProgress[player] = 0
	end

	-- Solo continúa si el jugador toca el checkpoint correcto en orden
	if id == playerProgress[player] + 1 then
		playerProgress[player] = id
		-- Activa el evento
		nextP:Fire(player, id)
	end
end

-- Conecta el evento "Touched" a cada parte con tag "checkp"
for _, checkpoint in ipairs(checkpoints) do
	checkpoint.Touched:Connect(function(hit)
		onCheckpointTouched(checkpoint, hit)
	end)
end

-- Limpieza al salir el jugador
Players.PlayerRemoving:Connect(function(player)
	playerProgress[player] = nil
end)

