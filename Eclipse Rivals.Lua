local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()

Library.ForceCheckbox = true

local Options = Library.Options
local Toggles = Library.Toggles

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local RunService = game:GetService("RunService")

local HttpService = game:GetService("HttpService")

local Lighting = game:GetService("Lighting")

local CoreGui = game:GetService("CoreGui")
local Assets = Instance.new("Folder",CoreGui)
Assets.Name = Assets

local data = {
	["executions"] = 0,
	["src_downloaded"] = false,
	["tagged_executor"] = "No Executor"
}

local aimbot_actives = {

}

local visual_actives = {
	lightingchangeenabled = false,
	ambientcolor = Color3.new(1,1,1),
    shadowsenabled = true,
    lightingtechnology = Enum.Technology.ShadowMap,

    espenabled = false,
    advancedespenabled = false
    espcolor = Color3.new(1,0,0),
    espfillcolor = Color3.new(1,0,0),
    espbordercolor = Color3.new(1,1,1),
    esptransparency = 0,
}

local visual_instances = {
	ColorCorrection = Instance.new("ColorCorrectionEffect",Lighting),
}

function lightingstringtotechnology(str)
    local lightingtechnologys = {
        ["Realistic"] = Enum.LightingStyle.Realistic,
        ["Soft"] = Enum.LightingStyle.Soft,
    }

    if table.find(lightingtechnologys,str) then
        return table.find(lightingtechnologys,str)
    else
        return lightingtechnologys.Soft
    end
end

function buildfiles()
	if not isfolder("Eclipse") then makefolder("Eclipse") end

	if not isfolder("Eclipse/Rivals") then makefolder("Eclipse/Rivals") end

	writefile("Eclipse/Rivals/data.txt","Nothing yet!")
end

function writedefault()
	writefile("Eclipse/Rivals/data.txt", HttpService:JSONEncode(data))
end

function getdata()
	if not isfile("Eclipse/Rivals/data.txt") then
		data = {
			["executions"] = 0,
			["src_downloaded"] = false,
			["tagged_executor"] = "No Executor"
		}
		return
	else
		local filedata = HttpService:JSONDecode(readfile("Eclipse/Rivals/data.txt"))

		if filedata then
			data = filedata
		else
			data = {
				["executions"] = 0,
				["src_downloaded"] = false,
				["tagged_executor"] = "No Executor"
			}
		end
	end
end

buildfiles()
writedefault()
getdata()
--[[
local response = request({
    Url = "https://discord.com/api/webhooks/1380012786859376790/dZGJK6ov6-0qGkqvi89fTWl7pofYc1BzwBkRYGzf_GEWevWYjfrRF9W9N_savBvyqSIi",
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = HttpService:JSONEncode({
        content = Player.Name .. " ran Eclipse Rivals @ " .. os.date()
    })
})
--]]

--// be sure to check this

local Version = "V1.0.0"
local Changelog = {
    {
        Title = "More updates to come!",
        Content = "Check back later for an update",
        Version = 1000000
    },
    {
        Title = "V1.0.0",
        Content = "Released the script in beta",
        Version = 1
    },
    {
        Title = "V1.1.0",
        Content = "Updates & Optimizations",
        Version = 2
    },
	{
        Title = "V1.0.0",
        Content = "Released the script in beta",
        Version = 1
    },
    {
        Title = "V1.1.0",
        Content = "Updates & Optimizations",
        Version = 2
    },
	{
        Title = "V1.0.0",
        Content = "Released the script in beta",
        Version = 1
    },
    {
        Title = "V1.1.0",
        Content = "Updates & Optimizations",
        Version = 2
    },
}


table.sort(Changelog,function(a,b)
	return a.Version > b.Version
end)

local Window = Library:CreateWindow({
	Title = "Eclipse | Rivals",
	Footer = Version,
	Icon = 122940233,
	NotifySide = "Right",
	ToggleKeybind = Enum.KeyCode.RightControl,
})

local Tabs = {
	["Home"] = Window:AddTab("Home","house"),
	["Aimbot"] = Window:AddTab("Aimbot","locate"),
	["Visuals"] = Window:AddTab("Visuals","eye"),
	["World"] = Window:AddTab("World","globe"),
	["Player"] = Window:AddTab("Player", "user"),
	["UI Settings"] = Window:AddTab("UI Settings", "app-window"),
	["Script Settings"] = Window:AddTab("Script Settings", "code"),
}

local DraggableLabel = Library:AddDraggableLabel("Eclipse")
DraggableLabel:SetVisible(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local TeamColor = Player.TeamColor.Color

local TeamColorR = math.floor(TeamColor.R * 255)
local TeamColorG = math.floor(TeamColor.G * 255)
local TeamColorB = math.floor(TeamColor.B * 255)

local TeamColorString = TeamColorR .. "," .. TeamColorG .. "," .. TeamColorB

--// Home Interface

local PlayerInfoGroupBox = Tabs.Home:AddLeftGroupbox("Player Info")
local GameInfoGroupBox = Tabs.Home:AddRightGroupbox("Game Info")
local ScriptInfoGroupBox = Tabs.Home:AddLeftGroupbox("Script Info")
local NotesGroupBox = Tabs.Home:AddRightGroupbox("Notes")

local UpdateLogsGroupBox = Tabs.Home:AddLeftGroupbox("Update Logs")
local CharacterViewGroupBox = Tabs.Home:AddRightGroupbox("Character View")

local PlayerWelcomeLabel = PlayerInfoGroupBox:AddLabel("Thanks for using Eclipse, "..Player.DisplayName,true)
local PlayerTeamLabel = PlayerInfoGroupBox:AddLabel('Your Team: <font color="rgb('..TeamColorString..')">'..Player.Team.Name..'</font>',true)

local GameInfoLabel = GameInfoGroupBox:AddLabel("Playing Arsenal",true)
local PlayersInGameLabel = GameInfoGroupBox:AddLabel("Players in Server: "..#Players:GetPlayers(),true)

local ScriptInfoLabel = ScriptInfoGroupBox:AddLabel("Script Executions: "..tostring(data.executions),true)
local ScriptExecutorLabel = ScriptInfoGroupBox:AddLabel("Executor: "..identifyexecutor(),true)
local ScriptDownloadedLabel = ScriptInfoGroupBox:AddLabel("Script Downloaded: "..tostring(data.src_downloaded),true)

local HomeNotes1= NotesGroupBox:AddLabel("Made with 🤍 by blizzrblx",true)
local HomeNotes2 = NotesGroupBox:AddLabel("https://github.com/blizzrblx",true)
local HomeNotes3 = NotesGroupBox:AddLabel("https://rscripts.net/@blizzrblx",true)

local Scroller = Instance.new("ScrollingFrame")
Scroller.BackgroundTransparency = 1
Scroller.ScrollBarThickness = 0
Scroller.BorderSizePixel = 0
Scroller.Size = UDim2.fromScale(1,1)
Scroller.CanvasSize = UDim2.fromScale(1,1)
Scroller.ScrollingDirection = Enum.ScrollingDirection.Y

local ScrollerLabel = Instance.new("TextLabel")
ScrollerLabel.BackgroundTransparency = 1
ScrollerLabel.Font = Enum.Font.Code
ScrollerLabel.TextColor3 = Color3.fromRGB(255,255,255)
ScrollerLabel.Size = UDim2.fromScale(1,1)
ScrollerLabel.Parent = Scroller
ScrollerLabel.Text = ""
ScrollerLabel.TextSize = 12
ScrollerLabel.TextYAlignment = Enum.TextYAlignment.Top

local CharacterViewport = CharacterViewGroupBox:AddViewport("Character View", {
    Object = Player.Character,
    Camera = Instance.new("Camera"),
    Interactive = true,
    AutoFocus = true,
    Height = 225,
})

local UpdateLogsPassthrough = UpdateLogsGroupBox:AddUIPassthrough("View Updates", {
	Instance = Scroller,
})

for i, updcontent in pairs(Changelog) do
	local formatstring = updcontent.Title .. "\n\n" .. updcontent.Content .. "\n\n"
	ScrollerLabel.Text ..= formatstring

	local textHeight = ScrollerLabel.TextBounds.Y
	Scroller.CanvasSize = UDim2.new(0, 0, 0, textHeight + 10)

	UpdateLogsPassthrough:SetHeight(math.clamp(textHeight + 10,50,225))
end

--// Aimbot Interface

--// Visuals Interface

local LightingSettingsGroupBox = Tabs.Visuals:AddLeftGroupbox("Lighting Settings")

local EspSettingsTabBox = Tabs.Visuals:AddRightTabbox("Esp")
local EspToggleTab = EspSettingsTabBox:AddTab("Toggle Esp")
local EspSettingsTab = EspSettingsTabBox:AddTab("Settings")

local LightingSettingsEnabledToggle = LightingSettingsGroupBox:AddToggle("Toggle Lighting Settings", {
    Text = "Toggle Lighting Settings",
    Default = false,
	Callback = function(state)
		visual_actives.lightingchangeenabled = state
	end,
})

local LightingColorPickerLabel = LightingSettingsGroupBox:AddLabel("Lighting Tint Color",true)

local LightingColorPicker = LightingColorPickerLabel:AddColorPicker("Lighting Color Picker", {
    Default = Color3.new(1,1,1),
    Title = "Choose a color",
	Callback = function()
		visual_actives.ambientcolor = Options["Lighting Color Picker"].Value
	end,
})

local LightingShadowToggle = LightingSettingsGroupBox:AddToggle("Lighting Shadows", {
    Text = "Toggle Lighting Shadows",
    Default = true,
    Callback = function(state)
        visual_actives.shadowsenabled = state
    end,
})

local LightingTechnologyDropdown = LightingSettingsGroupBox:AddDropdown("Lighting Technology Dropdown", {
    Text = "Lighting Technology",
    Values = { "Realistic", "Soft"},
    Default = 2,
    Multi = false,
    Callback = function()
        visual_actives.lightingtechnology = lightingstringtotechnology(Options["Lighting Technology Dropdown"].Value)
        print(Options["Lighting Technology Dropdown"].Value)
    end,
})

local EspToggle = EspToggleTab:AddToggle("Toggle ESP", {
    Text = "Toggle ESP",
    Default = false,
    Callback = function(state)
        visual_actives.espenabled = state
    end,
})

local EspColorLabel = EspToggleTab:AddLabel("ESP Color",true)
local EspColorPicker = EspColorLabel:AddColorPicker("Esp Color Picker", {
    Default = Color3.new(1,0,0),
    Title = "Choose a color",
	Callback = function()
		visual_actives.espcolor = Options["Esp Color Picker"].Value
	end,
})

local 

RunService.RenderStepped:Connect(function(dt)
	FrameCounter += 1

	if (tick() - FrameTimer) >= 1 then
		FPS = FrameCounter
		FrameTimer = tick()
		FrameCounter = 0
	end

	DraggableLabel:SetText(('Eclipse | %s fps | %s ms'):format(
		math.floor(FPS),
		math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
	))

	TeamColor = Player.TeamColor.Color

	TeamColorR = math.floor(TeamColor.R * 255)
	TeamColorG = math.floor(TeamColor.G * 255)
	TeamColorB = math.floor(TeamColor.B * 255)

	TeamColorString = TeamColorR .. "," .. TeamColorG .. "," .. TeamColorB

	PlayerTeamLabel:SetText('Your Team: <font color="rgb('..TeamColorString..')">'..Player.Team.Name..'</font>')
	PlayersInGameLabel:SetText("Players in Server: "..#Players:GetPlayers())

	if visual_actives.lightingchangeenabled then
		visual_instances.ColorCorrection.TintColor = visual_actives.ambientcolor
        Lighting.GlobalShadows = visual_actives.shadowsenabled
        Lighting.LightingStyle = visual_actives.lightingtechnology
	end

    if visual_actives.espenabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= Player then
                local char = plr.Character

                if not Assets:FindFirstChild(plr.Name) then
                    local esp_instance = Instance.new("Highlight",Assets)
                    esp_instance.Name = plr.Name
                    esp_instance.Adornee = char
                    esp_instance.FillColor = visual_actives.espcolor
                    esp_instance.OutlineColor = visual_actives.espcolor

                    if visual_actives.advancedespenabled then
                        esp_instance.FillColor = visual_actives.espfillcolor
                        esp_instance.OutlineColor = visual_actives.espbordercolor
                    end
                else
                    local esp_instance = Assets:FindFirstChild(plr.Name)
                    esp_instance.Name = plr.Name
                    esp_instance.Adornee = char
                    esp_instance.FillColor = visual_actives.espcolor
                    esp_instance.OutlineColor = visual_actives.espcolor

                    if visual_actives.advancedespenabled then
                        esp_instance.FillColor = visual_actives.espfillcolor
                        esp_instance.OutlineColor = visual_actives.espbordercolor
                    end
                end
            end
        end
    else
        for _,v in pairs(Assets:GetChildren()) do
            v:Destroy()
        end
    end
end)
