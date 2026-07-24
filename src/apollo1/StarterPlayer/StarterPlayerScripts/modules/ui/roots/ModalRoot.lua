local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))

local useLobby = require(script.Parent.Parent.hooks.useLobby)
local LobbyPanel = require(script.Parent.Parent.components.lobby.LobbyPanel)

local function ModalRoot(props)
    local lobbyOpen = useLobby.useOpen()

    React.useEffect(function()
        if props.container then
            props.container.Enabled = lobbyOpen
        end
    end, { lobbyOpen, props.container })

    return React.createElement("Folder", {},
    {
        Lobby = React.createElement(LobbyPanel),
    })
end

return ModalRoot
