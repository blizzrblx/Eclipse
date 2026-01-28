local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "Eclipse | Phantom Forces",
    Footer = "VERSION: 1.0.0",
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
}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Http = game:GetService("HttpService")

local script_executions = 0,
local auto_exec = false

function writedirectory()
    makefolder("Eclipse")
    makefolder("Eclipse/Phantom_Forces")
    writefile("Eclipse/Phantom_Forces/data.txt","")
end

function writefiledata()
    writefile("Eclipse/Phantom_Forces/data.txt",Http:JSONEncode({
        ["script_executions"] = script_executions,
        ["auto_exec"] = auto_exec,
    }))
end

function filedata()
    local is_data = isfile("Eclipse/Phantom_Forces/data")

    if is_data then
        local data_tbl = Http:JSONDecode(readfile("Eclipse/Phantom_Forces/data.txt"))

        return data_tbl
    else
        return {
            0,false
        }
    end
end

local data = filedata()

script_executions = data.script_executions + 1
auto_exec = data.auto_exec

if auto_exec then
    
end
