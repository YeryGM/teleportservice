local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local UiSelectors = require(script.Parent.Parent.store.ui.UiSelectors)
local useStoreSelector = require(script.Parent.Parent.hooks.useStoreSelector)
local useLobby = require(script.Parent.Parent.hooks.useLobby)

local DeathPanel = require(script.Parent.Parent.components.death.DeathPanel)
local ShopPanel = require(script.Parent.Parent.components.shop.ShopPanel)
local CraftingPanel = require(script.Parent.Parent.components.crafting.CraftingPanel)
local LobbyPanel = require(script.Parent.Parent.components.lobby.LobbyPanel)

local function ModalRoot(props)
    local visible = useStoreSelector(UiSelectors.selectModalVisible)
    local lobbyOpen = useLobby.useOpen()
    
    React.useEffect(function()
        if props.container then
            props.container.Enabled = visible or lobbyOpen
        end
    end, { visible, lobbyOpen, props.container })

    return React.createElement("Folder", {}, 
    {
        Death = React.createElement(DeathPanel),
        Shop = React.createElement(ShopPanel),
        Crafting = React.createElement(CraftingPanel),
        Lobby = React.createElement(LobbyPanel),
    })
end

return ModalRoot
