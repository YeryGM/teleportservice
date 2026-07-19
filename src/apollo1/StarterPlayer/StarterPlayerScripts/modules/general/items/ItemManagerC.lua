local Crafting = require(script.Parent.actions.CraftingC)

local ItemManagerC = {
    loaded = false,
}

function ItemManagerC:load()
    if self.loaded then 
        return
    end

    Crafting:load()
    self.loaded = true
end

function ItemManagerC:unload()
    if not self.loaded then 
        return
    end
    Crafting:unload()
    self.loaded = false
end

return ItemManagerC