local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

--//CHECK THIS
--//////////////////////
local Version = "V1.0.0"

local Changelog = {
	["More Updates Coming Soon!"] = "Check back in a bit for more updates!",
    ["Update V1.0.0"] = "Released the beta version of the script",
}
--//////////////////////
--// CHECK THIS

local Player = Players.LocalPlayer
	
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua"))()

local lua_src = game:HttpGet("https://raw.githubusercontent.com/blizzrblx/Eclipse/refs/heads/main/Eclipse%20Phantom%20Forces.Lua")

local Window = Library:CreateWindow({
    Title = "Eclipse | PF",
    Footer = Version,
    Icon = 122940233,
    NotifySide = "Right",
    ToggleKeybind = Enum.KeyCode.RightControl,
})

local Tabs = {
    Home = Window:AddTab("Home", "house"),
    Aimbot = Window:AddTab("Aimbot", "locate"),
    Visual = Window:AddTab("Visuals", "eye"),
    Player = Window:AddTab("Player & Character", "user"),
    ["UI Settings"] = Window:AddTab("UI Settings", "app-window"),
    ["Script Settings"] = Window:AddTab("Script Settings", "cog")
}

if not isfolder("Eclipse") then makefolder("Eclipse") end
if not isfolder("Eclipse/PhantomForces") then makefolder("Eclipse/PhantomForces") end

local current_data = nil

if isfile("Eclipse/PhantomForces/data.txt") then
    current_data = HttpService:JSONDecode(readfile("Eclipse/PhantomForces/data.txt"))
else
    local default_data = {
        ["script_executions"] = 0,
        ["auto_exec"] = false,
        ["dev"] = false
    }

    writefile("Eclipse/PhantomForces/data.txt",HttpService:JSONEncode(default_data))

    current_data = default_data
end

local PlayerInfoBox = Tabs.Home:AddLeftGroupbox("Player Info")
local PlayerInfoBox_Name = PlayerInfoBox:AddLabel("Thanks for using Eclipse, "..Player.Name,true)
local PlayerInfoBox_Executions = PlayerInfoBox:AddLabel("Eclipse has been ran "..tostring(current_data.script_executions).." times",true)

local ViewportBox = Tabs.Home:AddLeftGroupbox("Character View")
local ViewportBox_Viewport = ViewportBox:AddViewport("CharacterViewport", {
	Object = Player.Character,
	Camera = Instance.new("Camera"),
	Interactive = true,
	AutoFocus = true,
	Height = 250,
})

local ScriptInfoBox = Tabs.Home:AddRightGroupbox("Script Info")
local ScriptVersion = ScriptInfoBox:AddLabel("Running Version: "..Version,true)

local Changelog_Scroller = Instance.new("ScrollingFrame")
Changelog_Scroller.ScrollBarThickness = 0
Changelog_Scroller.BackgroundTransparency = 1
Changelog_Scroller.Parent = workspace
Changelog_Scroller.Size = UDim2.new(1,0,1,0)

local Update_Label = Instance.new("TextLabel")
Update_Label.Font = Enum.Font.Code
Update_Label.BackgroundTransparency = 1
Update_Label.TextColor3 = Color3.fromRGB(255,255,255)
Update_Label.TextSize = 14
Update_Label.Parent = Changelog_Scroller
Update_Label.Text = "Changelog: \n\n"
Update_Label.TextWrapped = true
Update_Label.Size = UDim2.new(1,0,1,0)
Update_Label.TextYAlignment = Enum.TextYAlignment.Top

for updname,updcontent in pairs(Changelog) do
    Update_Label.Text = Update_Label.Text .. updname..":\n" .. updcontent.."\n\n"
end

local ScriptChangelog = ScriptInfoBox:AddUIPassthrough("Changelog", {
    Instance = Changelog_Scroller,
    Height = 250
})

local GameInfoBox = Tabs.Home:AddRightGroupbox("Game Info")
local GameName = GameInfoBox:AddLabel(game.Name,true)

if current_data.script_executions == 0 then PlayerInfoBox_Name:SetText("Welcome to Eclipse, "..Player.Name) end
