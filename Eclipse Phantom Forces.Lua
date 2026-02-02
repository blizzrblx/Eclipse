local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local RunService = game:GetService("RunService")

local Version = "V1.0.0"
local Changelog = {
    ["More updates to come!"] = "Check back later for an update",
    ["V1.0.0"] = "Released the script in beta",
}

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

local Default_Data = {
    ["executions"] = 0,
    ["src_downloaded"] = false,
}

local TeamColor = Player.TeamColor
local TeamColorR, TeamColorG, TeamColorB = TeamColor.r, TeamColor.g, TeamColor.b
local TeamColorString = tostring(TeamColorR..","..TeamColorG..","..TeamColorB)

--// Home Interface

local PlayerInfoGroupBox = Tabs.Home:AddLeftGroupbox("Player Info")
local GameInfoGroupBox = Tabs.Home:AddRightGroupbox("Game Info")

local PlayerTeamLabel = PlayerInfoGroupBox:AddLabel('Your Team: <font color="rgb(255,0,0)">'..Player.Team.Name..'</font>')

RunService.RenderStepped:Connect(function(dt)
    FrameCounter += 1;
 
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end
 
    DraggableLabel:SetText(('Eclipse | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)
