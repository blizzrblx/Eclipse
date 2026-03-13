local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local version = "V1.0.0"
local changelog = {
	{
		id = 9999,
		name = "More updates to come!",
		content = "Check back later for more updates!",
		color = Color3.fromRGB(255,255,255)
	},
	{
		id = 1,
		name = "V1.0.0",
		content = "Released the script",
		color = Color3.fromRGB(255,255,255)
	}
}

local basetheme = {
    1,
    { FontColor = "ffffff", MainColor = "191919", AccentColor = "7d55ff", BackgroundColor = "0f0f0f", OutlineColor = "282828" },
}

local actives = {
	visual = {
		data = {
			ESPColor = Color3.fromRGB(255,0,0),
			ESPEnabled = true,
			HighlightESPEnabled = false,
			HighlightESPColor = Color3.fromRGB(255,0,0),
			NametagESPEnabled = false,
			NametagESPColor = Color3.fromRGB(255,0,0),
			LineESPEnabled = false,
			LineESPColor = Color3.fromRGB(255,0,0),

			LightingTintColor = Color3.fromRGB(255,255,255),
			LightingTintSaturation = 1,
			LightingTintBrightness = 1,
			LightingTintContrast = 1,
			LightingTintEnabled = true,

			FullbrightEnabled = false,
			ShadowsEnabled = true,
			LightingClockTime = 14.5,
		},
		instances = {
			nametag = {},
			line = {},
			tint = Instance.new("ColorCorrectionEffect",Lighting)
		},
	},
	aimbot = {
		data = {
			Mode = "Hold",
			Enabled = false,
			Active = false,
			Keybind = Enum.UserInputType.MouseButton2,
			HighlightTarget = false,
			Smooth = 4,
			Prediction = 0,
			MaxTrackingDistance = 1000,
			FOVEnabled = false,
			FOV = 100
		},
		instances = {
			Closest = nil
		}
	},
	player = {
		data = {
			SpeedBoostEnabled = false,
			SpeedBoost = 0,
			InfJumpEnabled = false,
			JumpBoost = 0,
			JumpBoostEnabled = false
			NoClipEnabled = false,
		}
	}
}

local Assets = Instance.new("Folder",game:GetService("CoreGui"))
local AimbotTargetHighlight = Instance.new("Highlight",Assets)
local AimbotFOVCircle = Drawing.new("Circle")
AimbotFOVCircle.Visible = true
AimbotFOVCircle.Color = Color3.fromRGB(255, 0, 0)
AimbotFOVCircle.Transparency = 1
AimbotFOVCircle.Thickness = 1
AimbotFOVCircle.NumSides = 512
AimbotFOVCircle.Radius = 100
AimbotFOVCircle.Position = Vector2.new(
	Camera.ViewportSize.X / 2,
	Camera.ViewportSize.Y / 2
)

table.sort(changelog,function(a,b) 
	return a.id > b.id
end)

local defaultdata = {
	logged_executor = identifyexecutor(),
	script_executions = 0,
	current_version = version
}

local currentdata = defaultdata

function BuildDirectorys()
	if not isfolder("Eclipse") then
		makefolder("Eclipse")
	end

	if not isfolder("Eclipse/Rivals") then
		makefolder("Eclipse/Rivals")
	end

	if not isfolder("Eclipse/Rivals/Data") then
		makefolder("Eclipse/Rivals/Data")
	end

	if not isfile("Eclipse/Rivals/Data/scriptdata.txt") then
		writefile(
			"Eclipse/Rivals/Data/scriptdata.txt",
			Http:JSONEncode(defaultdata)
		)
	end
end

function ReadDirectorys()
	local filedata = Http:JSONDecode(readfile("Eclipse/Rivals/Data/scriptdata.txt"))
	currentdata = filedata
end

function DeleteDirectorys()
	delfolder("Eclipse/Rivals")
end

BuildDirectorys()
ReadDirectorys()

function HiglightESP()
	if actives.visual.data.ESPEnabled and actives.visual.data.HighlightESPEnabled then
		for i,plr in pairs(Players:GetPlayers()) do
			if not Assets:FindFirstChild(plr.Name) then
				local Highlight = Instance.new("Highlight")
				Highlight.Parent = Assets
				Highlight.Name = plr.Name
				Highlight.Adornee = plr.Character
				Highlight.FillColor = actives.visual.data.HighlightESPColor
				Highlight.OutlineColor = actives.visual.data.HighlightESPColor
			else
				local Highlight = Assets:FindFirstChild(plr.Name)
				Highlight.Parent = Assets
				Highlight.Name = plr.Name
				Highlight.Adornee = plr.Character
				Highlight.FillColor = actives.visual.data.HighlightESPColor
				Highlight.OutlineColor = actives.visual.data.HighlightESPColor

			end
		end
	else
		for i,v in pairs(Assets:GetChildren()) do v:Destroy() end
	end
end

local function removeESP(plr)
    local txt = actives.visual.instances.nametag[plr]
    if txt then
        txt:Remove()
        actives.visual.instances.nametag[plr] = nil
    end
end

local function UpdateNameESP()
    local alive = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        alive[plr] = true

        local char = plr.Character
        if not actives.visual.data.NametagESPEnabled or not actives.visual.data.ESPEnabled or not char then
            removeESP(plr)
            continue
        end

        local pos = char:GetPivot().Position + Vector3.new(0, 3, 0)
        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)

        if not onScreen then
            removeESP(plr)
            continue
        end

        if not actives.visual.instances.nametag[plr] then
            local txt = Drawing.new("Text")
            txt.Center = true
            txt.Outline = true
            txt.Size = 16
            actives.visual.instances.nametag[plr] = txt
        end

        local txt = actives.visual.instances.nametag[plr]
        txt.Text = plr.Name
        txt.Position = Vector2.new(screenPos.X, screenPos.Y)
        txt.Visible = true
		txt.Color = actives.visual.data.NametagESPColor
    end
    for plr in pairs(actives.visual.instances.nametag) do
        if not alive[plr] then
            removeESP(plr)
        end
    end
end

local function removeLine(plr)
    local line = actives.visual.instances.line[plr]
    if line then
        line:Remove()
        actives.visual.instances.line[plr] = nil
    end
end

function UpdateLineESP()
	if not actives.visual.instances.line then
		actives.visual.instances.line = {}
	end

	local alive = {}

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= Player then
			alive[plr] = true

			local char = plr.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")

			if not root or not actives.visual.data.LineESPEnabled or not actives.visual.data.ESPEnabled then
				removeLine(plr)
				continue
			end

			local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
			if not onScreen then
				removeLine(plr)
				continue
			end

			local origin = Vector2.new(
				Camera.ViewportSize.X/2,
				Camera.ViewportSize.Y/2
			)

			local line = actives.visual.instances.line[plr]
			if not line then
				line = Drawing.new("Line")
				line.Thickness = 2
				line.Transparency = 1
				actives.visual.instances.line[plr] = line
			end

			line.From = origin
			line.To = Vector2.new(pos.X, pos.Y)
			line.Color = actives.visual.data.LineESPColor
			line.Visible = true
		end
	end
	
	for plr in pairs(actives.visual.instances.line) do
        if not alive[plr] then
            removeLine(plr)
        end
    end
end

function GetClosestCharacter()
	local character = Player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local closest = nil
	local closestDistance = math.huge

	local mousePos = UIS:GetMouseLocation()

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= Player then
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")

			if hrp then
				local worldDist = (hrp.Position - root.Position).Magnitude
				if worldDist <= actives.aimbot.data.MaxTrackingDistance then

					local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
					if onScreen then

						local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

						if actives.aimbot.data.FOVEnabled then
							if screenDist > actives.aimbot.data.FOV then
								continue
							end
						end

						if screenDist < closestDistance then
							closestDistance = screenDist
							closest = char
						end
					end
				end
			end
		end
	end

	return closest
end

function SetClosest()
    actives.aimbot.instances.Closest = GetClosestCharacter()
end

function LookAtTarget(deltaTime)
    if not (actives.aimbot.data.Enabled and actives.aimbot.data.Active) then return end
    if not actives.aimbot.instances.Closest then return end

    local targetPart = actives.aimbot.instances.Closest:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end

    local predictionTime = actives.aimbot.data.Prediction
    local velocity = targetPart.AssemblyLinearVelocity

    local predictedPosition = targetPart.Position + (velocity * predictionTime)

    local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPosition)
    if not onScreen then return end

    local mousePos = UIS:GetMouseLocation()

    local deltaX = screenPos.X - mousePos.X
    local deltaY = screenPos.Y - mousePos.Y

    local smooth = math.max(actives.aimbot.data.Smooth, 1)

    deltaX = (deltaX / smooth) * deltaTime * 60
    deltaY = (deltaY / smooth) * deltaTime * 60

    local maxMove = 50
    deltaX = math.clamp(deltaX, -maxMove, maxMove)
    deltaY = math.clamp(deltaY, -maxMove, maxMove)

    mousemoverel(deltaX, deltaY)
end

function SetSpeed(dt)
    if not actives.player.data.SpeedBoostEnabled then return end

    local char = Player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    local moveDir = hum.MoveDirection
    if moveDir.Magnitude == 0 then
        return
    end

    local targetSpeed = hum.WalkSpeed + actives.player.data.SpeedBoost

    local horizontalVel = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)

    local desiredVel = moveDir * targetSpeed

    local accel = 8
    local newVel = horizontalVel:Lerp(desiredVel, math.clamp(accel * dt, 0, 1))

    hrp.Velocity = Vector3.new(
        newVel.X,
        hrp.Velocity.Y,
        newVel.Z
    )
end

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()

Library.ForceCheckbox = true
local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Eclipse | Rivals",
    Footer = version,
    Icon = "eclipse",
    NotifySide = "Right",
})

local Tabs = {
	Home = Window:AddTab("Home","house"),
	Visuals = Window:AddTab("Visuals","eye"),
	Aimbot = Window:AddTab("Aimbot","locate"),
	Player = Window:AddTab("Player","user"),
	Ragebot = Window:AddTab("Rage", "skull")
	["UI Settings"] = Window:AddTab("UI Settings", "app-window"),
	["Script Settings"] = Window:AddTab("Script Settings", "monitor-cog")
}

Library:Notify({
	Title = "Eclipse",
	Description = "Thanks for using Eclipse!",
	Time = 4,
})
ThemeManager:SetLibrary(Library)
ThemeManager:SetDefaultTheme(basetheme)
ThemeManager:SetFolder("Eclipse") 
ThemeManager:ApplyToTab(Tabs["UI Settings"])
ThemeManager:LoadDefault()

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("Eclipse/Rivals")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

local DraggableLabel = Library:AddDraggableLabel("Eclipse Rivals")

--//Home UI

local HomeLeftGroupBox = Tabs.Home:AddLeftGroupbox("Player Info", "user")
local HomeRightGroupBox = Tabs.Home:AddRightGroupbox("Script Info","monitor")

local ErrorLogsGroupBox = Tabs.Home:AddLeftGroupbox("Error Logs", "ban")
local ChangelogGroupBox = Tabs.Home:AddRightGroupbox("Changelogs", "list")

if currentdata.script_executions == 0 then
	HomeLeftGroupBox:AddLabel('Welcome To Eclipse, <font color="rgb(0,205,0)">['..Player.DisplayName.."]</font>",true)
else
	HomeLeftGroupBox:AddLabel('Thanks for using Eclipse, <font color="rgb(0,205,0)">['..Player.DisplayName.."]</font>",true)
end

local PlayersInServerLabel = HomeLeftGroupBox:AddLabel("Players in server: "..tostring(#Players:GetPlayers()))

local ErrorLogsLabel = Instance.new("TextLabel")
ErrorLogsLabel.BackgroundTransparency = 1
ErrorLogsLabel.TextColor3 = Color3.fromRGB(255,255,255)
ErrorLogsLabel.BorderSizePixel = 0
ErrorLogsLabel.Font = Enum.Font.Code
ErrorLogsLabel.Text = "Error Logs:"
ErrorLogsLabel.Size = UDim2.fromScale(1,1)
ErrorLogsLabel.TextSize = 14
ErrorLogsLabel.TextWrapped = true
ErrorLogsLabel.TextXAlignment = Enum.TextXAlignment.Center
ErrorLogsLabel.TextYAlignment = Enum.TextYAlignment.Top
ErrorLogsLabel.RichText = true

local ChangelogScroller = Instance.new("ScrollingFrame",game:GetService("CoreGui"))
ChangelogScroller.BackgroundTransparency = 1
ChangelogScroller.CanvasSize = UDim2.fromScale(1,1)
ChangelogScroller.Size = UDim2.fromScale(1,1)
ChangelogScroller.ScrollingDirection = Enum.ScrollingDirection.Y
ChangelogScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ChangelogLabel = ErrorLogsLabel:Clone()
ChangelogLabel.Parent = ChangelogScroller
ChangelogLabel.Text = "Change Logs\n\n"

local ErrorLogsPassthrough = ErrorLogsGroupBox:AddUIPassthrough("Error Logs", {
    Instance = ErrorLogsLabel,
	Height = 250
})

local ChangesLogsPassthrough = ChangelogGroupBox:AddUIPassthrough("Change Logs",{
	Instance = ChangelogScroller,
	Height = 250
})

for _, upd in ipairs(changelog) do
	local c = upd.color or Color3.new(1,1,1)
	local r,g,b = c.R*255, c.G*255, c.B*255

	ChangelogLabel.Text ..=
		"<font color=\"rgb("..r..","..g..","..b..")\">"
		.. upd.name
		.. "</font>\n"
		.. upd.content
		.. "\n\n"
end


HomeRightGroupBox:AddLabel("Eclipse is running on: "..identifyexecutor(),true)
HomeRightGroupBox:AddLabel("The current version is: "..version,true)

local ErrorModule = {}

function ErrorModule:newError(Settings:{Title:string, Message:string, Status:string})
	local title = Settings.Title or "Unknown"
	local message = Settings.Message or "No message provided"
	local status = Settings.Status or "Info"

	local color = "rgb(255,255,255)"

	if status == "Error" then
		color = "rgb(225,0,0)"
		Library:Notify({
			Title = "Eclipse",
			Description = "Error!",
			Time = 4,
		})
	elseif status == "Warning" then
		color = "rgb(255,230,0)"
	end

	ErrorLogsLabel.Text =
		ErrorLogsLabel.Text
		.. "\n\n"
		.. title
		.. "\n\n<font color=\""
		.. color
		.. "\">["
		.. message
		.. "]</font>"
end


ErrorModule:newError({
	Title = "Eclipse",
	Message = "Script ran successfully",
	Status = "Output",
})
ErrorModule:newError({
	Title = "Eclipse",
	Message = "Thanks for using Eclipse",
	Status = "Output"
})

--// Visuals UI

local HighlightESPGroupBox = Tabs.Visuals:AddLeftGroupbox("ESP (Highlight)", "square-user")
local NametagESPGroupBox = Tabs.Visuals:AddRightGroupbox("ESP (Nametag)", "tag")
local LineESPGroupBox = Tabs.Visuals:AddLeftGroupbox("ESP (Line)", "spline")
local ESPSettingsGroupBox = Tabs.Visuals:AddRightGroupbox("ESP Settings", "cog")

local LightingEffectsGroupBox = Tabs.Visuals:AddLeftGroupbox("Lighting Effects", "sun")
local LightingSettingsGroupBox = Tabs.Visuals:AddRightGroupbox("Lighting Settings","cog")

local esptog1 = HighlightESPGroupBox:AddToggle("HighlightESPToggle", {
    Text = "Toggle Highlight ESP",
    Default = false,
	Callback = function(state)
		actives.visual.data.HighlightESPEnabled = state
	end,
	Tooltip = "Toggle's Highlight-Based ESP",
})

local HighlightESPColor = HighlightESPGroupBox:AddLabel("Highlight ESP Color"):AddColorPicker("HighlightESPColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Title = "Pick A Color",
	Callback = function(color)
		actives.visual.data.HighlightESPColor = color
	end,
	Tooltip = "Set's the color of Highlight-Based ESP",
})

local esptog2 = NametagESPGroupBox:AddToggle("NametagESPToggle", {
	Text = "Toggle Nametag ESP",
	Default = false,
	Callback = function(state)
		actives.visual.data.NametagESPEnabled = state
	end,
	Tooltip = "Toggle Nametag ESP. Better for Low-End Devices",
})

local NametagESPColor = NametagESPGroupBox:AddLabel("Nametag ESP Color"):AddColorPicker("NametagESPColor", {
	Default = Color3.fromRGB(255,0,0),
	Title = "Pick A Color",
	Callback = function(color)
		actives.visual.data.NametagESPColor = color
	end,
	Tooltip = "Set's the color of Nametag ESP",
})

local esptog3 = LineESPGroupBox:AddToggle("LineESPToggle", {
	Text = "Toggle Tracers",
	Default = false,
	Callback = function(state)
		actives.visual.data.LineESPEnabled = state
	end,
	Tooltip = "Toggle's ESP Tracers",
})

local LineESPColor = LineESPGroupBox:AddLabel("Tracer Color"):AddColorPicker("LineESPColor", {
	Default = Color3.fromRGB(255,0,0),
	Title = "Pick A Color",
	Callback = function(color)
		actives.visual.data.LineESPColor = color
	end,
	Tooltip = "Set's the color of ESP Tracers",
})

ESPSettingsGroupBox:AddToggle("ESPEnabled", {
	Text = "Toggle ESP",
	Default = true,
	Callback = function(state)
		actives.visual.data.ESPEnabled = state
		if state == false then
			esptog1:SetValue(state)
			esptog2:SetValue(state)
			esptog3:SetValue(state)
		end
	end,
	Tooltip = "Toggles all ESP on or off",
})


ESPSettingsGroupBox:AddLabel("ESP Color"):AddColorPicker("ESPColor", {
	Default = Color3.fromRGB(255,0,0),
	Title = "Pick A Color",
	Callback = function(color)
		Options["HighlightESPColor"]:SetValueRGB(color)
		Options["NametagESPColor"]:SetValueRGB(color)
		Options["LineESPColor"]:SetValueRGB(color)
		actives.visual.data.ESPColor = color
		actives.visual.data.HighlightESPColor = color
		actives.visual.data.NametagESPColor = color
		actives.visual.data.LineESPColor = color
	end,
	Tooltip = "Set's the color for all ESP",
})

LightingSettingsGroupBox:AddLabel("Lighting Tint Color"):AddColorPicker("LightingColor", {
	Default = Color3.fromRGB(255,255,255),
	Title = "Pick A Color",
	Callback = function(color)
		actives.visual.data.LightingTintColor = color
	end,
	Tooltip = "Set's the tint color of the Lighting",
})

LightingSettingsGroupBox:AddSlider("LightingBrightness", {
    Text = "Brightness",
    Default = 1,
    Min = 0,
    Max = 2,
    Rounding = 2,
	Callback = function(value)
		actives.visual.data.LightingTintBrightness = value
	end,
	Tooltip = "Control how Bright it is",
})

LightingSettingsGroupBox:AddSlider("LightingContrast", {
    Text = "Contrast",
    Default = 1,
    Min = 0,
    Max = 2,
    Rounding = 2,
	Callback = function(value)
		actives.visual.data.LightingTintContrast = value
	end,
	Tooltip = "Control the Contrast",
})

LightingSettingsGroupBox:AddSlider("LightingSaturation", {
    Text = "Saturation",
    Default = 1,
    Min = 0,
    Max = 2,
    Rounding = 2,
	Callback = function(value)
		actives.visual.data.LightingTintSaturation = value
	end,
	Tooltip = "Control the Saturation",
})

LightingSettingsGroupBox:AddToggle("LightingTintToggle", {
    Text = "Toggle Lighting Tints",
    Default = false,
	Callback = function(state)
		actives.visual.data.LightingTintEnabled = state
	end,
	Tooltip = "Toggles all Lighting tints on or off",
})

LightingEffectsGroupBox:AddLabel("It's reccomended to turn of lighting tints before using fullbright",true)

LightingEffectsGroupBox:AddToggle("LightingEffectFullbright", {
	Text = "Toggle Fullbright",
	Default = false,
	Callback = function(state)
		actives.visual.data.FullbrightEnabled = state
	end,
	Tooltip = "Toggles Fullbright on or off",
})

LightingEffectsGroupBox:AddToggle("LightingEffectShadows", {
	Text = "Toggle Shadows",
	Default = false,
	Callback = function(state)
		actives.visual.data.ShadowsEnabled = state
	end,
	Tooltip = "Toggles all Shadows on or off",
})

LightingEffectsGroupBox:AddSlider("LightingTime", {
	Text = "Clock Time",
	Default = 12,
	Min = 0,
	Max = 24,
	Rounding = 1,
	Callback = function(value)
		actives.visual.data.LightingClockTime = value
	end,
	Tooltip = "Control the Time",
})

local AimbotToggleGroupBox = Tabs.Aimbot:AddLeftGroupbox("Aimbot", "crosshair")
local GunModsGroupBox = Tabs.Aimbot:AddLeftGroupbox("Gun Mods", "wrench")

AimbotToggleGroupBox:AddToggle("AimbotEnabled", {
	Text = "Toggle Aimbot",
	Default = false,
	Callback = function(state)
		actives.aimbot.data.Enabled = state
	end,
	Tooltip = "Toggle Aimbot on or off"
})

AimbotToggleGroupBox:AddLabel("Aimbot Toggle Key: "):AddKeyPicker("AimbotKeybind", {
	Text = "Select A Keybind",
	Default = "MB2",
	Mode = "Toggle",
	Callback = function(Key)

	end,
	Tooltip = "Pick a key for the aimbot"
})

AimbotToggleGroupBox:AddDropdown("AimbotMode", {
    Text = "Aimbot Mode",
    Values = {"Hold", "Toggle"},
    Default = 1,
    Multi = false,
	Callback = function(val)
		actives.aimbot.data.Mode = val
	end,
	Tooltip = "Pick a mode for the aimbot"
})

AimbotToggleGroupBox:AddSlider("AimbotSensitivity", {
	Text = "Aimbot Smoothing",
	Default = 4,
	Min = 1,
	Max = 16,
	Rounding = 1,
	Callback = function(value)
		actives.aimbot.data.Smooth = value
	end,
	Tooltip = "Control how smooth aimbot is",
})

AimbotToggleGroupBox:AddToggle("AimbotFOVEnabled", {
	Text = "Toggle Aimbot FOV",
	Default = false,
	Callback = function(state)
		actives.aimbot.data.FOVEnabled = state
	end,
	Tooltip = "Toggle aimbot fov",
})

AimbotToggleGroupBox:AddInput("AimbotFOVInput", {
	Default = "100",
	Numeric = true,
	Finished = true,
	ClearTextOnFocus = true,
 
	Text = "Aimbot FOV",
	Tooltip = "Enter a number",
 
	Placeholder = "Numbers between 1-1000 work best",
 
	Callback = function(value)
		actives.aimbot.data.FOV = tonumber(value)
	end,
})

--// Player UI

local SpeedBoostGroupBox = Tabs.Player:AddLeftGroupbox("Speed Boost", "gauge")
local CharacterEffectsGroupBox = Tabs.Player:AddRightGroupbox("Character Effects", "user-pen")

SpeedBoostGroupBox:AddToggle("SpeedBoostEnabled", {
	Text = "Toggle Speed Boost",
	Default = false,
	Callback = function(state)
		actives.player.data.SpeedBoostEnabled = state
	end,
	Tooltip = "Toggle Speed Boost (Undetected)"
})

SpeedBoostGroupBox:AddInput("SpeedBoostInput", {
	Default = "100",
	Numeric = true,
	Finished = true,
	ClearTextOnFocus = true,
 
	Text = "Speed Boost Amount",
	Tooltip = "Enter a number",
 
	Placeholder = "Numbers between 50-300 work best",
 
	Callback = function(value)
		actives.player.data.SpeedBoost = tonumber(value)
	end,
})

CharacterEffectsGroupBox:AddToggle("NoClipEnabled", {
	Text = "Toggle NoClip",
	Default = false,
	Callback = function(state)
		actives.player.data.NoClipEnabled = not state
	end,
	Tooltip = "Allows you to walk through walls"
})

CharacterEffectsGroupBox:AddToggle("InfJumpEnabled", {
	Text = "Toggle Infinite Jump",
	Default = false,
	Callback = function(state)
		actives.player.data.InfJumpEnabled = state
	end,
	Tooltip = "Allows you to jump midair"
})

CharacterEffectsGroupBox:AddToggle("JumpBoostEnabled", {
	Text = "Toggle Jump Boost",
	Default = false,
	Callback = function(state)
		actives.player.data.JumpBoostEnabled = state
	end,
	Tooltip = "Jump higher and longer"
})

CharacterEffectsGroupBox:AddInput("JumpBoostInput", {
	Default = "0",
	Numeric = true,
	Finished = true,
	ClearTextOnFocus = true,

	Text = "Jump Boost Amount",
	Tooltip = "Enter a number",
 
	Placeholder = "Numbers between 50-300 work best",

	Callback = function(value)
		actives.player.data.JumpBoost = tonumber(value)
	end,
})

local FrameTimer = time()
local FrameCounter = 0
local FPS = 60

local AimToggle = false

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not actives.aimbot.data.Enabled then return end

	local keybind = actives.aimbot.data.Keybind
	if not keybind then return end

	if input.UserInputType == keybind or input.KeyCode == keybind then
		if actives.aimbot.data.Mode == "Toggle" then
			AimToggle = not AimToggle
			actives.aimbot.data.Active = AimToggle
		else
			actives.aimbot.data.Active = true
		end
	end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not actives.aimbot.data.Enabled then return end

	local keybind = actives.aimbot.data.Keybind
	if not keybind then return end

	if actives.aimbot.data.Mode == "Hold" then
		if input.UserInputType == keybind or input.KeyCode == keybind then
			actives.aimbot.data.Active = false
		end
	end
end)

UIS.JumpRequest:Connect(function()
	if actives.player.data.InfJumpEnabled then
		if Player.Character and Player.Character.Humanoid then
			Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end

	if actives.player.data.JumpBoostEnabled then
		if Player.Character and Player.Character.Humanoid then
			local state = Player.Character.Humanoid.FloorMaterial

			if state == Enum.Material.Air then
				if actives.player.data.InfJumpEnabled then
					local Vector = Vector3.new(0,actives.player.data.JumpBoost,0)
					Player.Character.HumanoidRootPart.Velocity = Player.Character.HumanoidRootPart.Velocity + Vector
				end
			else
				local Vector = Vector3.new(0,actives.player.data.JumpBoost,0)
				Player.Character.HumanoidRootPart.Velocity = Player.Character.HumanoidRootPart.Velocity + Vector
			end
		end
	end
end)

RunService.RenderStepped:Connect(function(deltaTime)
	PlayersInServerLabel:SetText("Players in server: "..tostring(#Players:GetPlayers()),true)
    FrameCounter = FrameCounter + 1
 
    if (time() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = time()
        FrameCounter = 0
    end
 
    DraggableLabel:SetText(('Eclipse Rivals | %s fps | %s ms'):format(tostring( math.floor(FPS)),tostring(math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()))))

	HiglightESP()
	UpdateNameESP()
	UpdateLineESP()

	local tint = actives.visual.instances.tint

	tint.TintColor = actives.visual.data.LightingTintColor
	tint.Brightness = actives.visual.data.LightingTintBrightness
	tint.Saturation = actives.visual.data.LightingTintSaturation
	tint.Contrast = actives.visual.data.LightingTintContrast
	tint.Enabled = actives.visual.data.LightingTintEnabled

	if actives.visual.data.FullbrightEnabled then
		Lighting.ClockTime = 12
	else
		Lighting.ClockTime = actives.visual.data.LightingClockTime
	end
	Lighting.GlobalShadows = actives.visual.data.ShadowsEnabled

	if actives.aimbot.data.Enabled and actives.aimbot.data.Active then
		SetClosest()
		LookAtTarget(deltaTime)
	end

	AimbotFOVCircle.Position = UIS:GetMouseLocation()
	AimbotFOVCircle.Radius = actives.aimbot.data.FOV or 100
	AimbotFOVCircle.Visible = actives.aimbot.data.FOVEnabled
	SetSpeed(deltaTime)
	if Player.Character then
		for i,limb in pairs(Player.Character:GetChildren()) do
			if limb:IsA("BasePart") then limb.CanCollide = actives.player.data.NoClipEnabled end
		end
	end
end)
