local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("React"))
local RootStore = require(script.Parent.Parent.store.RootStore)

local function defaultEquality(a, b)
    if a == b then
        return true
    end

    if type(a) ~= "table" or type(b) ~= "table" then
        return false
    end
    for k, v in pairs(a) do
        if b[k] ~= v then
            return false
        end
    end
    for k in pairs(b) do
        if a[k] == nil then
            return false
        end
    end
    return true
end

local function useStoreSelector(selector, equalityFn)
    local eq = equalityFn or defaultEquality

    local selected, setSelected = React.useState(function()
        return selector(RootStore.getState())
    end)

    local selectedRef = React.useRef(selected)
    selectedRef.current = selected

    local selectorRef = React.useRef(selector)
    selectorRef.current = selector

    local eqRef = React.useRef(eq)
    eqRef.current = eq

    React.useEffect(function()
        local function handleChange()
            local nextSelected = selectorRef.current(RootStore.getState())
            if not eqRef.current(nextSelected, selectedRef.current) then
                selectedRef.current = nextSelected
                setSelected(nextSelected)
            end
        end

        local unsubscribe = RootStore.subscribe(handleChange)
        handleChange()

        return function()
            unsubscribe()
        end
    end, {})

    return selected
end

return useStoreSelector
