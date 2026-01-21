local Sidebar = {}
Sidebar.__index = Sidebar  

local open = false

function Sidebar:new()
	local gethuienabled,no = pcall(function()
		gethui()
	end)
	
	local gui = Instance.new("ScreenGui")
	gui.Name = "Sidebar"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 100
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
	if gethuienabled then gui.Parent = gethui() end
	
	local main = Instance.new("Frame")
	main.Size = UDim2.fromScale(0.2,0.9)
	main.BackgroundColor3 = Color3.fromRGB(37,37,37)
	main.Parent = gui
	main.Position = UDim2.fromScale(1.1,0.5)
	main.AnchorPoint = Vector2.new(0.5,0.5)
	
	local main_corner = Instance.new("UICorner")
	main_corner.CornerRadius = UDim.new(0,10)
	main_corner.Parent = main
	
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.fromScale(1,1)
	scroll.CanvasSize = UDim2.fromScale(1,1)
	scroll.ScrollBarThickness = 0
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.BackgroundColor3 = Color3.fromRGB(37,37,37)
	scroll.BackgroundTransparency = 1
	scroll.Parent = main
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.fromScale(0.9,0.125)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0,10)
	padding.PaddingRight = UDim.new(0,10)
	padding.PaddingTop = UDim.new(0,10)
	padding.PaddingBottom = UDim.new(0,10)
	
	layout.Parent = scroll
	padding.Parent = scroll
	
	local openclose = Instance.new("TextButton")
	openclose.BackgroundColor3 = Color3.fromRGB(37,37,37)
	openclose.Position = UDim2.fromScale(-0.5,0.5)
	openclose.Size = UDim2.fromScale(0.2,0.2)
	openclose.SizeConstraint = Enum.SizeConstraint.RelativeXX
	openclose.Text = "<b>‹</b>"
	openclose.Font = Enum.Font.Ubuntu
	openclose.TextSize = 40
	openclose.TextColor3 = Color3.fromRGB(255,255,255)
	openclose.Parent = main
	openclose.RichText = true
	
	openclose.MouseButton1Down:Connect(function()
		open = not open

		if open then
			openclose.Text = "<b>›</b>"
			game:GetService("TweenService"):Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(0.85,0.5)}):Play()
		else
			openclose.Text = "<b>‹</b>"
			game:GetService("TweenService"):Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(1.1,0.5)}):Play()
		end
	end)
	local openclose_corner = Instance.new("UICorner")
	openclose_corner.CornerRadius = UDim.new(1)
	openclose_corner.Parent = openclose
	
	local mt = {}
	mt.main = main
	Sidebar.main = main
	
	return setmetatable(mt,Sidebar)
end

function Sidebar:NewToggle(Settings)
	local new = Instance.new("TextButton")
	new.BackgroundColor3 = Color3.fromRGB(47,47,47)
	new.Size = UDim2.fromOffset(0.4,0.1)
	new.TextColor3 = Color3.fromRGB(255,255,255)
	new.RichText = true
	new.Text = Settings.Text..'[<font color = "rgb(205,0,0)">Disabled</font>]'
	new.Parent = self.main.ScrollingFrame
	new.Font = Enum.Font.Ubuntu
	new.TextSize = 30
	new.BorderSizePixel = 0
	
	local new_corner = Instance.new("UICorner") 
	new_corner.CornerRadius = UDim.new(0,10)
	new_corner.Parent = new
	
	local enabled = Settings.Default

	Settings.Callback(enabled)
	
	new.MouseButton1Down:Connect(function()
		enabled = not enabled
		
		Settings.Callback(enabled)
		
		if enabled then
			new.Text = Settings.Text..'[<font color = "rgb(0,205,0)">Enabled</font>]'
		else
			new.Text = Settings.Text..'[<font color = "rgb(205,0,0)">Disabled</font>]'
		end
	end)
end

function Sidebar:NewInput(Settings)
	local new = Instance.new("TextBox")
	new.BackgroundColor3 = Color3.fromRGB(47,47,47)
	new.Size = UDim2.fromOffset(0.4,0.1)
	new.TextColor3 = Color3.fromRGB(255,255,255)
	new.RichText = true
	new.PlaceholderText = Settings.Placeholder or ""
	new.Parent = self.main.ScrollingFrame
	new.Font = Enum.Font.Ubuntu
	new.TextSize = 30
	new.BorderSizePixel = 0
	
	if Settings.Numeric then
		new:GetPropertyChangedSignal("Text"):Connect(function()
			new.Text = new.Text:gsub('%D+', '');
		end)
	end
	
	new.FocusLost:Connect(function()
		Settings.Callback(new.Text)
	end)
	
	local new_corner = Instance.new("UICorner") 
	new_corner.CornerRadius = UDim.new(0,10)
	new_corner.Parent = new
end

return Sidebar
