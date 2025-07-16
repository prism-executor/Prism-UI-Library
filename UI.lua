-- UI.lua
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local UI = {}

local dragging, dragInput, dragStart, startPos = false

function UI.CreateWindow(title, version)
	local screenGui = Instance.new("ScreenGui", game.CoreGui)
	screenGui.Name = "PrismUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 400, 0, 500)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Parent = screenGui
	
	local uicorner = Instance.new("UICorner", frame)
	uicorner.CornerRadius = UDim.new(0, 10)

	local titleLabel = Instance.new("TextLabel", frame)
	titleLabel.Size = UDim2.new(1, 0, 0, 40)
	titleLabel.Text = title .. " | " .. version
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

	-- Dragging Support (Mobile+PC)
	titleLabel.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.Touch then
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

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	local tabContainer = Instance.new("Frame", frame)
	tabContainer.Size = UDim2.new(1, -20, 1, -60)
	tabContainer.Position = UDim2.new(0, 10, 0, 50)
	tabContainer.BackgroundTransparency = 1

	local layout = Instance.new("UIListLayout", tabContainer)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 20)

	local function CreateTab(name)
		local tab = Instance.new("Frame", tabContainer)
		tab.Size = UDim2.new(0.5, -10, 1, 0)
		tab.BackgroundTransparency = 1

		local innerLayout = Instance.new("UIListLayout", tab)
		innerLayout.Padding = UDim.new(0, 10)
		innerLayout.SortOrder = Enum.SortOrder.LayoutOrder

		return tab
	end

	function UI.CreateLeftGroup(tab)
		return createGroup(tab, Enum.TextXAlignment.Left)
	end

	function UI.CreateRightGroup(tab)
		return createGroup(tab, Enum.TextXAlignment.Right)
	end

	function createGroup(parent, alignment)
		local group = {}

		function group.CreateToggle(name, default, callback)
			local toggle = Instance.new("TextButton", parent)
			toggle.Size = UDim2.new(1, 0, 0, 35)
			toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
			toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
			toggle.TextSize = 16
			toggle.Font = Enum.Font.Gotham
			toggle.Text = name .. ": " .. (default and "ON" or "OFF")

			local state = default
			toggle.MouseButton1Click:Connect(function()
				state = not state
				toggle.Text = name .. ": " .. (state and "ON" or "OFF")
				callback(state)
			end)
		end

		function group.CreateSlider(name, min, max, default, callback)
			local sliderFrame = Instance.new("Frame", parent)
			sliderFrame.Size = UDim2.new(1, 0, 0, 35)
			sliderFrame.BackgroundTransparency = 1

			local label = Instance.new("TextLabel", sliderFrame)
			label.Size = UDim2.new(1, 0, 0, 15)
			label.Position = UDim2.new(0, 0, 0, 0)
			label.Text = name .. ": " .. tostring(default)
			label.TextSize = 14
			label.TextColor3 = Color3.new(1, 1, 1)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.Gotham

			local bar = Instance.new("Frame", sliderFrame)
			bar.Size = UDim2.new(1, 0, 0, 10)
			bar.Position = UDim2.new(0, 0, 1, -10)
			bar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
			bar.BorderSizePixel = 0

			local fill = Instance.new("Frame", bar)
			fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
			fill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
			fill.BorderSizePixel = 0

			local dragging = false

			local function updateFill(x)
				local barAbs = bar.AbsolutePosition.X
				local barSize = bar.AbsoluteSize.X
				local clamped = math.clamp((x - barAbs) / barSize, 0, 1)
				fill:TweenSize(UDim2.new(clamped, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
				local value = math.floor(min + clamped * (max - min))
				label.Text = name .. ": " .. value
				callback(value)
			end

			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					updateFill(input.Position.X)
				end
			end)

			UIS.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateFill(input.Position.X)
				end
			end)

			UIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
		end

		return group
	end

	return frame, CreateTab
end

return UI
