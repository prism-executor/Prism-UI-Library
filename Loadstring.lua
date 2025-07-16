local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUser/YourRepo/main/UI.lua"))()

local combatTab = UI.CreateTab("Combat")
local visualsTab = UI.CreateTab("Visuals")

UI.CreateToggle(combatTab, "Speed Hack", false, function(state)
    print("Speed Hack toggled", state)
end)

UI.CreateSlider(combatTab, "Speed Amount", 0, 100, 50, function(value)
    print("Speed Amount set to", value)
end)

UI.CreateToggle(visualsTab, "ESP", false, function(state)
    print("ESP toggled", state)
end)
