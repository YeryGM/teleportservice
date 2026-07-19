local Objectives = {
    [1] =  {
        children = {2, 3}, --children required to be completed
        prev = nil,
        next = 2,
        text = "Find the key",
    }, 
    [2] =  {
        children = {},
        prev = {1},
        next = 3,
        text = "Open the door",
    },
    [3] =  {
        children = {},
        prev = {1,2}, --requires both 1 and 2 to be started
        next = nil,
        text = "Retrieve the artifact",
    }, 
}

return Objectives