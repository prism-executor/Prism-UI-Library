local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/prism-executor/Prism-UI-Library/main/UI.lua"))()

UI.CreateWindow("My UI", "v1.0")

local tab = UI.CreateTab("Settings")

local leftGroup = UI.CreateLeftGroup(tab)
local rightGroup = UI.CreateRightGroup(tab)

leftGroup.CreateToggle("God Mode", false, function(state)
    print("God Mode:", state)
end)

leftGroup.CreateSlider("Speed", 0, 100, 50, function(value)
    print("Speed:", value)
end)

rightGroup.CreateToggle("Noclip", true, function(state)
    print("Noclip:", state)
end)

rightGroup.CreateSlider("Jump Power", 10, 200, 50, function(value)
    print("Jump Power:", value)
end)
