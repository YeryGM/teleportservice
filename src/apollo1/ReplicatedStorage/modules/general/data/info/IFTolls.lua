-- the number is the pairId, the boolean is whether it's the first or second toll in the pair, 
-- and the array is {zoneA, zoneB} where zoneA is the zone for the first toll and zoneB is the zone for the second toll
local Enums = require(script.Parent.Parent.Enums)

local Tolls = {
    [1] = {
        [true] = {[1] = Enums.zones.Alleys, [2] = Enums.zones.Chocobank}, 
        [false] = {[1] = Enums.zones.Chocobank, [2] = Enums.zones.Alleys}
    },
    [2] = {
        [true] = {[1] = Enums.zones.Chocobank, [2] = Enums.zones.Chocofall}, 
        [false] = {[1] = Enums.zones.Chocofall, [2] = Enums.zones.Chocobank}
    },
    [3] = {
        [true] = {[1] = Enums.zones.Chocofall, [2] = Enums.zones.Chocofountain}, 
        [false] = {[1] = Enums.zones.Chocofountain, [2] = Enums.zones.Chocofall}
    },
    
}
return Tolls