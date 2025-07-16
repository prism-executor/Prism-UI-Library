local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/prism-executor/Prism-UI-Library/main/UI.lua"))()

local window, CreateTab = UI.CreateWindow("Prism", "v1.0")
local tab = CreateTab("Exploits")

local leftGroup = UI.CreateLeftGroup(tab)
local rightGroup = UI.CreateRightGroup(tab)
leftGroup.CreateToggle({
    Text = "God Mode",
    Default = false,
    Callback = function(state)
        print("God Mode toggled:", state)
    end
})

leftGroup.CreateSlider({
    Text = "Speed",
    Min = 0,
    Max = 100,
    Default = 16,
    Callback = function(value)
        print("Speed value:", value)
    end
})
