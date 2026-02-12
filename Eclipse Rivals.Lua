local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local version = "V1.0.0"
local changelog = {
	{
		[1] = 9999,
		[2] = "More updates to come!",
		[3] = "Check back later for more updates!"
	},
	{
		[1] = 1,
		[2] = "V1.0.0",
		[3] = "Released the script"
	}
}

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

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()

local Window = Library:CreateWindow({
    Title = "Eclipse | Rivals",
    Footer = version,
    Icon = 122940233,
    NotifySide = "Right",
})

local Tabs = {
	Home = Window:AddTab("Home","house"),
	Visuals = Window:AddTab("Visuals","eye"),
	Aimbot = Window:AddTab("Aimbot","locate"),
	Player = Window:AddTab("Player","user"),
	["UI Settings"] = Window:AddTab("UI Settings", "app-window"),
	["Script Settings"] = Window:AddTab("Script Settings", "monitor-cog")
}

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("Eclipse") 
ThemeManager:ApplyToTab(Tabs["UI Settings"])
ThemeManager:LoadDefault()

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("Eclipse/Rivals")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
