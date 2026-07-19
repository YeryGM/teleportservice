local StateMachine = {}
StateMachine.__index = StateMachine

-- Constructor
function StateMachine.new()
	local self = setmetatable({}, StateMachine)
	self.states = {}
	self.currentState = nil
	self.transitioning = false
	self.onStateChanged = nil
	self.currentThreads = {} -- Track running threads for cleanup
	self.debugOn = false
	return self
end

-- Enable internal logging
function StateMachine:EnableDebug()
	self.debugOn = true
end

-- Optional callback to listen for all state transitions
function StateMachine:SetStateChangedCallback(callback)
	self.onStateChanged = callback
end

-- Register a new state with optional enter/exit handlers
function StateMachine:AddState(name, onEnter, onExit)
	assert((type(name) == "string" or type(name) == "number"), "State name must be a string or number")
	self.states[name] = {
		Enter = onEnter or function() end,
		Exit = onExit or function() end
	}
end

-- Change state safely, with optional force
function StateMachine:SetState(newState, force, ...)
	assert((type(newState) == "string" or type(newState) == "number"), "New state must be a string or number")

	-- Prevent double transitions unless forced
	if self.transitioning then
		if self.debugOn then
			warn("[StateMachine] Attempted transition to " .. tostring(newState) .. " while transitioning")
		end
		return
	end

	-- Prevent same state transition unless forced
	if self.currentState == newState and not force then
		if self.debugOn then
			print("[StateMachine] Already in state " .. tostring(newState) .. ", ignoring transition")
		end
		return
	end

	-- Check state is valid before starting transition
	if not self.states[newState] then
		warn("State '" .. tostring(newState) .. "' is not registered")
		return
	end

	self.transitioning = true

	local prevState = self.currentState
	local args = {...} -- Capture varargs to pass to spawned functions

	-- Cancel all running threads from previous state
	for _, thread in ipairs(self.currentThreads) do
		if coroutine.status(thread) ~= "dead" then
			task.cancel(thread)
			if self.debugOn then
				print("[StateMachine] Cancelled running thread from state " .. tostring(prevState))
			end
		end
	end
	self.currentThreads = {}

	-- Exit current state in a spawned thread
	if self.states[prevState] and self.states[prevState].Exit then
		local exitThread = task.spawn(function()
			local success, err = pcall(self.states[prevState].Exit, table.unpack(args))
			if not success then
				warn("Error during Exit of state " .. tostring(prevState) .. ": " .. err)
			end
		end)
		table.insert(self.currentThreads, exitThread)
	end

	-- Update state
	local oldState = self.currentState
	self.currentState = newState

	-- Notify listeners BEFORE entering new state
	if self.onStateChanged then
		local success, err = pcall(self.onStateChanged, oldState, newState)
		if not success then
			warn("Error in state changed callback: " .. err)
		end
	end

	if self.debugOn then
		print(string.format("[StateMachine] %s -> %s", tostring(oldState), tostring(newState)))
	end

	-- Enter new state in a spawned thread
	local enterThread = task.spawn(function()
		local success, err = pcall(self.states[newState].Enter, table.unpack(args))
		if not success then
			warn("Error during Enter of state " .. tostring(newState) .. ": " .. err)
		end
	end)
	table.insert(self.currentThreads, enterThread)

	self.transitioning = false
end

-- Get the current state
function StateMachine:GetState()
	return self.currentState
end

-- Check if a state exists
function StateMachine:HasState(name)
	return self.states[name] ~= nil
end

-- Force cleanup (useful for debugging)
function StateMachine:Cleanup()
	-- Cancel all running threads
	for _, thread in ipairs(self.currentThreads) do
		if coroutine.status(thread) ~= "dead" then
			task.cancel(thread)
		end
	end
	self.currentThreads = {}

	-- Exit current state if exists
	if self.currentState and self.states[self.currentState] and self.states[self.currentState].Exit then
		local success, err = pcall(self.states[self.currentState].Exit)
		if not success then
			warn("Error during cleanup Exit: " .. err)
		end
	end

	self.currentState = nil
	self.transitioning = false
end

return StateMachine