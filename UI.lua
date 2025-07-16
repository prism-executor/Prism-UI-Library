local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local UI = {}

-- Tween helper
local function tweenObject(object, properties, duration)
    local tween = TweenService:Create(object, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

-- Draggable with mouse & mobile touch
local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    local function updatePosition(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

    -- Mouse movement for drag
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput and input.UserInputType == Enum.UserInputType.MouseMovement then
            updatePosition(input)
        end
    end)

    -- Touch movement for drag (TouchMoved event)
    UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
        if dragging and dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and touch.UserInputState ~= Enum.UserInputState.End then
            updatePosition(touch)
        end
    end)
end

-- Mobile-friendly slider dragging
local function makeSliderDraggable(sliderBar, sliderFill, label, text, min, max, callback)
    local dragging = false

    local function updateSlider(input)
        local relativeX = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
        local ratio = relativeX / sliderBar.AbsoluteSize.X
        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        local value = math.floor(min + (max - min) * ratio)
        label.Text = text .. ": " .. value
        if callback then callback(value) end
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)

    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    UserInputService.TouchMoved:Connect(function(touch, _)
        if dragging and touch.UserInputState ~= Enum.UserInputState.End then
            updateSlider(touch)
        end
    end)
end

-- UI Containers: left & right groups for better layout and spacing on mobile
function UI.CreateLeftGroup(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.5, -10, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)  -- spacing between toggles/sliders
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame

    -- Provide API on the frame to add toggles/sliders with spacing
    local groupAPI = {}

    function groupAPI.CreateToggle(text, default, callback)
        return UI.CreateToggle(frame, text, default, callback)
    end

    function groupAPI.CreateSlider(text, min, max, default, callback)
        return UI.CreateSlider(frame, text, min, max, default, callback)
    end

    return groupAPI
end

function UI.CreateRightGroup(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.5, -10, 1, 0)
    frame.Position = UDim2.new(0.5, 10, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame

    local groupAPI = {}

    function groupAPI.CreateToggle(text, default, callback)
        return UI.CreateToggle(frame, text, default, callback)
    end

    function groupAPI.CreateSlider(text, min, max, default, callback)
        return UI.CreateSlider(frame, text, min, max, default, callback)
    end

    return groupAPI
end

-- CreateWindow, CreateTab, CreateToggle and CreateSlider remain mostly the same, except
-- Update slider creation to call makeSliderDraggable for full mobile support:

function UI.CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
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

    makeSliderDraggable(sliderBar, sliderFill, label, text, min, max, callback)

    return frame
end

UI.makeDraggable = makeDraggable

return UI
