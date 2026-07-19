local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Enums = require(ReplicatedStorage.modules.general.data.Enums)

local DeviceDetector = {}

local PLATFORM = {
	PC = Enums.platform.PC,
	Mobile = Enums.platform.Mobile,
	Console = Enums.platform.Console,
}

DeviceDetector.PLATFORM = PLATFORM
DeviceDetector.DEFAULT_VALID = {
	[PLATFORM.PC] = true,
	[PLATFORM.Mobile] = true,
}

local function safeGetConnectedGamepads()
	local ok, connected = pcall(function()
		return UserInputService:GetConnectedGamepads()
	end)
	if not ok or type(connected) ~= "table" then
		return nil
	end
	return connected
end

local function collectSignals()
	local connectedGamepads = safeGetConnectedGamepads()
	local hasConnectedGamepad = connectedGamepads and #connectedGamepads > 0 or false

	return {
		touchEnabled = UserInputService.TouchEnabled,
		keyboardEnabled = UserInputService.KeyboardEnabled,
		mouseEnabled = UserInputService.MouseEnabled,
		gamepadEnabled = UserInputService.GamepadEnabled,
		gyroEnabled = UserInputService.GyroscopeEnabled,
		accelEnabled = UserInputService.AccelerometerEnabled,
		tenFootInterface = GuiService:IsTenFootInterface(),
		hasConnectedGamepad = hasConnectedGamepad,
	}
end

local function classify(signals)
	if signals.tenFootInterface then
		return PLATFORM.Console
	end

	if signals.touchEnabled and (signals.gyroEnabled or signals.accelEnabled) and not signals.keyboardEnabled and not signals.mouseEnabled then
		return PLATFORM.Mobile
	end
	if signals.touchEnabled and not signals.keyboardEnabled and not signals.mouseEnabled then
		return PLATFORM.Mobile
	end
	if (signals.gamepadEnabled or signals.hasConnectedGamepad) and not signals.keyboardEnabled and not signals.mouseEnabled and not signals.touchEnabled then
		return PLATFORM.Console
	end

	return PLATFORM.PC
end

function DeviceDetector.getPlatformInfo(validMap)
	local signals = collectSignals()
	local platform = classify(signals)
	local allowed = validMap or DeviceDetector.DEFAULT_VALID
	local isValid = allowed[platform] == true
    if isValid then
        return platform
    else
        return nil
    end
end

return DeviceDetector