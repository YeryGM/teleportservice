local Players = {
    [1] = {
        maxHealth = 100,
        stamina = {
                maxStamina = 100,
                regenRate = 5,
                drainRate = 10,
            },
        hiding = {
            time = 1, -- time it takes for the player to be considered fully hidden 
        }
    },

}
return Players