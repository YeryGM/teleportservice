local UiEnums = {
    UiMode = {
        None = 0,
        Gameplay = 1,
        Cutscene = 2,
        Minigame = 3,
        Crafting = 4,
        Shop = 5,
        Spectator = 6,
        Dead = 7,
    },
    uiComponents = {
        hud = 101,
        objectives = 102,
        stamina = 103,
        qte = 104,
        subtitles = 105,
        cutscene = 106,
        minigame = 107,
        crafting = 108,
        shop = 109,
        death = 110,
    },
}

UiEnums.Components = {
    [UiEnums.UiMode.Gameplay] = {
        [UiEnums.uiComponents.hud] = true,
        [UiEnums.uiComponents.objectives] = true,
        [UiEnums.uiComponents.stamina] = true,
        [UiEnums.uiComponents.qte] = true,
        [UiEnums.uiComponents.subtitles] = true,
    },
    [UiEnums.UiMode.Cutscene] = {
        [UiEnums.uiComponents.subtitles] = true,
        [UiEnums.uiComponents.cutscene] = true,
    },
    [UiEnums.UiMode.Minigame] = {
        [UiEnums.uiComponents.minigame] = true,
    },
    [UiEnums.UiMode.Crafting] = {
        [UiEnums.uiComponents.crafting] = true,
    },
    [UiEnums.UiMode.Shop] = {
        [UiEnums.uiComponents.shop] = true,
    },
    [UiEnums.UiMode.Spectator] = {
        [UiEnums.uiComponents.hud] = true,
    },
    [UiEnums.UiMode.Dead] = {
        [UiEnums.uiComponents.death] = true,
    },
}

UiEnums.Transitions = {
    [UiEnums.UiMode.Gameplay] = {
        [UiEnums.UiMode.Cutscene] = true,
        [UiEnums.UiMode.Minigame] = true,
        [UiEnums.UiMode.Crafting] = true,
        [UiEnums.UiMode.Shop] = true,
        [UiEnums.UiMode.Spectator] = true,
        [UiEnums.UiMode.Dead] = true,
    },
    [UiEnums.UiMode.Cutscene] = {
        [UiEnums.UiMode.Gameplay] = true,
    },
    [UiEnums.UiMode.Minigame] = {
        [UiEnums.UiMode.Gameplay] = true,
    },
    [UiEnums.UiMode.Crafting] = {
        [UiEnums.UiMode.Gameplay] = true,
        [UiEnums.UiMode.Cutscene] = true,
        [UiEnums.UiMode.Minigame] = true,
        [UiEnums.UiMode.Shop] = true,
        [UiEnums.UiMode.Spectator] = true,
        [UiEnums.UiMode.Dead] = true,
    },
    [UiEnums.UiMode.Shop] = {
        [UiEnums.UiMode.Gameplay] = true,
        [UiEnums.UiMode.Cutscene] = true,
        [UiEnums.UiMode.Minigame] = true,
        [UiEnums.UiMode.Crafting] = true,
        [UiEnums.UiMode.Spectator] = true,
        [UiEnums.UiMode.Dead] = true,
    },
    [UiEnums.UiMode.Spectator] = {
        [UiEnums.UiMode.Gameplay] = true,
        [UiEnums.UiMode.Dead] = true,
    },
    [UiEnums.UiMode.Dead] = {
        [UiEnums.UiMode.Gameplay] = true,
    },
}

return UiEnums
