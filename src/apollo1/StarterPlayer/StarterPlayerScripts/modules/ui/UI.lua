local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packages = ReplicatedStorage:WaitForChild("packages")
local React = require(packages:WaitForChild("React"))
local ReactRoblox = require(packages:WaitForChild("ReactRoblox"))

local GameplayRoot = require(script.Parent.roots.GameplayRoot)
local OverlayRoot = require(script.Parent.roots.OverlayRoot)
local MinigameRoot = require(script.Parent.roots.MinigameRoot)
local ModalRoot = require(script.Parent.roots.ModalRoot)
local UISLobby = require(script.Parent.services.UISLobby)

local UiRootC = {
    roots = {},
    guis = {},
}

local function getOrCreateScreenGui(playerGui, name, displayOrder)
    local existing:ScreenGui = playerGui:FindFirstChild(name)
    if existing and existing:IsA("ScreenGui") then
        existing.DisplayOrder = displayOrder or existing.DisplayOrder
        existing.IgnoreGuiInset = true
        existing.ResetOnSpawn = false
        existing.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        existing.Enabled = false
        return existing
    end

    local gui:ScreenGui = Instance.new("ScreenGui")
    gui.Name = name
    gui.DisplayOrder = displayOrder or 1
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Enabled = false
    gui.Parent = playerGui
    return gui
end

function UiRootC:mountRoot(rootComponent, screenGui)
    local root = ReactRoblox.createRoot(screenGui)
    root:render(React.createElement(rootComponent, { container = screenGui }))
    self.roots[screenGui.Name] = root
    self.guis[screenGui.Name] = screenGui
end

function UiRootC:load()
    local player = Players.LocalPlayer
    if not player then
        return
    end
    local playerGui = player:WaitForChild("PlayerGui")

    local gameplayGui = getOrCreateScreenGui(playerGui, "UiGameplayGui", 1)
    local overlayGui = getOrCreateScreenGui(playerGui, "UiOverlayGui", 10)
    local minigameGui = getOrCreateScreenGui(playerGui, "UiMinigameGui", 20)
    local modalGui = getOrCreateScreenGui(playerGui, "UiModalGui", 30)

    self:mountRoot(GameplayRoot, gameplayGui)
    self:mountRoot(OverlayRoot, overlayGui)
    self:mountRoot(MinigameRoot, minigameGui)
    self:mountRoot(ModalRoot, modalGui)

    UISLobby.init()
end

function UiRootC:unload()
    for _, root in pairs(self.roots) do
        root:unmount()
    end
    self.roots = {}
    self.guis = {}
end

return UiRootC
