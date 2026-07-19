local Enums = require(script.Parent.Parent.Enums).story.dialogues

local Dialogues = {
    [Enums.fb1] = { 
        lane = 1,
        cues = {
            [1] =   {
                time = 0,
                text = "Hello, welcome to our game!",
                speaker = "MC",
                --duration = 3, optional can be passed via options too
                event = false,
                sound = {
                    soundId = "rbxassetid://1234567890",
                    volume = 0.8,
                    additional = {
                        TimePosition = 0,
                        RollOffMode = Enum.RollOffMode.Linear,
                        RollOffMinDistance = 10,
                        RollOffMaxDistance = 100,
                        PlaybackSpeed = 1,
                        Looped = false,
                        PlayOnRemove = false,
                    }
                },
            },
            [2] = {
                time = 3,
                text = "Enjoy your adventure!",
                speaker = "Guide",
                sound = {
                    soundId = "rbxassetid://0987654321",
                    volume = 0.7,
                    additional = {
                        TimePosition = 0,
                        RollOffMode = Enum.RollOffMode.Linear,
                        RollOffMinDistance = 10,
                        RollOffMaxDistance = 100,
                        PlaybackSpeed = 1,
                        Looped = false,
                        PlayOnRemove = false,
                    }
                },
            }
        }
    },
}
return Dialogues