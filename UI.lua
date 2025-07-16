-- UI.lua
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local UI = {}

-- ScreenGui parent
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModularUILibrary"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Tween helper with smoother easing
local function tweenObject(object, properties, duration)
    local tween = TweenService:Create(object, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

-- Draggable function
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Create main window
local window = Instance.new("Frame")
window.Name = "MainWindow"
window.Size = UDim2.new(0, 450, 0, 320)
window.Position = UDim2.new(0.5, -225, 0.5, -160)
window.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
window.BorderSizePixel = 0
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Parent = screenGui
makeDraggable(window)

-- Rounded corners
local windowCorner = Instance.new("UICorner")
windowCorner.CornerRadius = UDim.new(0, 8)
windowCorner.Parent = window

-- Animate window fade-in
window.BackgroundTransparency = 1
tweenObject(window, {BackgroundTransparency = 0}, 0.4)

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleBar.Parent = window

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Modular UI Library"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 22
titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Tab buttons container
local tabButtons = Instance.new("Frame")
tabButtons.Size = UDim2.new(0, 110, 1, -32)
tabButtons.Position = UDim2.new(0, 0, 0, 32)
tabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
tabButtons.Parent = window

local tabButtonsCorner = Instance.new("UICorner")
tabButtonsCorner.CornerRadius = UDim.new(0, 8)
tabButtonsCorner.Parent = tabButtons

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = tabButtons

-- Tab content container
local tabContent = Instance.new("Frame")
tabContent.Size = UDim2.new(1, -110, 1, -32)
tabContent.Position = UDim2.new(0, 110, 0, 32)
tabContent.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
tabContent.Parent = window

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = tabContent

local tabs = {}
local currentTab = nil

-- Create a tab
function UI.CreateTab(name)
    -- Create button
    local btn = Instance.new("TextButton")
    btn.Text = name
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 18
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.Parent = tabButtons

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    -- Hover effects
    btn.MouseEnter:Connect(function()
        tweenObject(btn, {BackgroundColor3 = Color3.fromRGB(70, 70, 90)}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        if not currentTab or currentTab.Name ~= name then
            tweenObject(btn, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}, 0.15)
        end
    end)

    -- Tab content frame
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = tabContent

    btn.MouseButton1Click:Connect(function()
        if currentTab then
            currentTab.Visible = false
            tabs[currentTab.Name].Button.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        end
        content.Visible = true
        currentTab = content
        currentTab.Name = name
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    end)

    tabs[name] = {Frame = content, Button = btn}
    return content
end

-- Create a toggle button inside a parent frame
function UI.CreateToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(210, 210, 230)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 22)
    toggleBtn.Position = UDim2.new(1, -60, 0, 4)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(70, 70, 90)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleBtn

    local enabled = default

    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        tweenObject(toggleBtn, {BackgroundColor3 = enabled and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(70, 70, 90)}, 0.2)
        toggleBtn.Text = enabled and "ON" or "OFF"
        if callback then
            callback(enabled)
        end
    end)

    return frame
end

-- Create a slider inside a parent frame
function UI.CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = text .. ": " .. default
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(210, 210, 230)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, 0, 0, 12)
    sliderBar.Position = UDim2.new(0, 0, 0, 30)
    sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    sliderBar.Parent = frame
    sliderBar.ClipsDescendants = true
    sliderBar.AnchorPoint = Vector2.new(0, 0)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    sliderFill.Parent = sliderBar

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 5)
    sliderCorner.Parent = sliderBar

    local dragging = false

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
            local ratio = relativeX / sliderBar.AbsoluteSize.X
            sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            local value = math.floor(min + (max - min) * ratio)
            label.Text = text .. ": " .. value
            if callback then
                callback(value)
            end
        end
    end)

    return frame
end

return UI
