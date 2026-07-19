
local State = {
    diff = 0,
    device = 0
}

function State.setDifficulty(difficulty: number)
    State.diff = difficulty
end

function State.getDifficulty(): number
    return State.diff
end

function State.setDevice(device: number)
    State.device = device
end

function State.getDevice(): number
    return State.device
end

return State