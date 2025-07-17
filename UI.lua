local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local UI = {}

-- Tween helper
local function tweenObject(object, properties, duration)
    local tween = TweenService:Create(object, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

-- Draggable window frame (mouse + mobile)
local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput 
            and (input.UserInputType == Enum.UserInputType.MouseMovement
                 or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.TouchMoved:Connect(function(touch)
        if dragging and touch.UserInputState ~= Enum.UserInputState.End then
            local delta = touch.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Slider draggable bar (mobile-ready)
local function makeSliderDraggable(sliderBar, sliderFill, label, text, min, max, callback)
    local dragging = false
    local lastTween
    local function update(pos)
        local rel = math.clamp((pos.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        if lastTween then lastTween:Cancel() end
        lastTween = TweenService:Create(sliderFill, TweenInfo.new(0.15), {Size = UDim2.new(rel,0,1,0)})
        lastTween:Play()
        local value = math.floor(min + (max - min) * rel)
        label.Text = text .. ": " .. value
        if callback then callback(value) end
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position)
        end
    end)
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position)
        end
    end)
    UserInputService.TouchMoved:Connect(function(touch)
        if dragging then update(touch.Position) end
    end)
end

-- UI Construction

function UI.CreateWindow(titleText)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModularUILibrary"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local window = Instance.new("Frame")
    window.Name = "MainWindow"
    window.Size = UDim2.new(0,450,0,500)
    window.Position = UDim2.new(0.5,0,0.5,50)
    window.AnchorPoint = Vector2.new(0.5,0.5)
    window.BackgroundColor3 = Color3.fromRGB(30,30,30)
    window.BorderSizePixel = 0
    window.ClipsDescendants = true
    window.Parent = screenGui

    -- Animate in
    window.BackgroundTransparency = 1
    tweenObject(window, {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5,0,0.5,0)
    }, 0.5)

    makeDraggable(window)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1,0,0,32)
    titleBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    titleBar.Parent = window

    local title = Instance.new("TextLabel")
    title.Text = titleText or "Modular UI Library"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1,-20,1,0)
    title.Position = UDim2.new(0,10,0,0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Tabs
    local tabButtons = Instance.new("Frame")
    tabButtons.Size = UDim2.new(0,110,1,-32)
    tabButtons.Position = UDim2.new(0,0,0,32)
    tabButtons.BackgroundColor3 = Color3.fromRGB(25,25,25)
    tabButtons.Parent = window

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = tabButtons

    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1,-110,1,-32)
    tabContent.Position = UDim2.new(0,110,0,32)
    tabContent.BackgroundColor3 = Color3.fromRGB(40,40,40)
    tabContent.Parent = window

    local tabs = {}
    local currentTab

    function UI.CreateTab(name)
        local btn = Instance.new("TextButton")
        btn.Text = name
        btn.Size = UDim2.new(1,-10,0,38)
        btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 18
        btn.TextColor3 = Color3.fromRGB(220,220,220)
        btn.Parent = tabButtons

        btn.MouseEnter:Connect(function()
            tweenObject(btn, {BackgroundColor3 = Color3.fromRGB(70,70,70)}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            if tabs[name] ~= currentTab then
                tweenObject(btn, {BackgroundColor3 = Color3.fromRGB(45,45,45)}, 0.15)
            end
        end)

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1,0,1,0)
        content.BackgroundTransparency = 1
        content.Visible = false
        content.Parent = tabContent

        btn.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.Visible = false
                tabs[currentTab.Name].Button.BackgroundColor3 = Color3.fromRGB(45,45,45)
            end
            content.Visible = true
            currentTab = content
            currentTab.Name = name
            tweenObject(btn, {BackgroundColor3 = Color3.fromRGB(85,55,145)}, 0.2)
        end)

        tabs[name] = {Frame = content, Button = btn}
        return content
    end

    return window, UI.CreateTab
end

function UI.CreateLeftGroup(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.5, -10, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame

    local api = {}
    function api.CreateToggle(opts) return UI.CreateToggle(frame, opts) end
    function api.CreateSlider(opts) return UI.CreateSlider(frame, opts) end
    return api
end

function UI.CreateRightGroup(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.5, -10, 1, 0)
    frame.Position = UDim2.new(0.5,10,0,0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame

    local api = {}
    function api.CreateToggle(opts) return UI.CreateToggle(frame, opts) end
    function api.CreateSlider(opts) return UI.CreateSlider(frame, opts) end
    return api
end

function UI.CreateToggle(parent, opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.7,0,0,30)
    btn.Position = UDim2.new(1,-60,0,4)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = opts.Default and Color3.fromRGB(85,55,145) or Color3.fromRGB(170,0,0)
    btn.Text = opts.Text or "New Button"
    btn.Parent = frame

    tweenObject(btn, {BackgroundColor3 = btn.BackgroundColor3}, 0)

    btn.MouseButton1Click:Connect(function()
        opts.Default = not opts.Default
        btn.Text = opts.Text or "New Button"
        tweenObject(btn, {BackgroundColor3 = opts.Default and Color3.fromRGB(85,55,145) or Color3.fromRGB(170,0,0)}, 0.2)
        if opts.Callback then opts.Callback(opts.Default) end
    end)

    return frame
end

function UI.CreateSlider(parent, opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = (opts.Text or "Slider") .. ": " .. (opts.Default or opts.Min or 0)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(210,210,230)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,0,0,20)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1,0,0,12)
    sliderBar.Position = UDim2.new(0,0,0,30)
    sliderBar.BackgroundColor3 = Color3.fromRGB(60,60,80)
    sliderBar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(((opts.Default or opts.Min or 0) - (opts.Min or 0)) 
        / ((opts.Max or 100) - (opts.Min or 0)),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(110,90,255)
    fill.Parent = sliderBar

    makeSliderDraggable(sliderBar, fill, label, opts.Text, opts.Min or 0, opts.Max or 100, opts.Callback)
    return frame
end

UI.makeDraggable = makeDraggable
return UI
