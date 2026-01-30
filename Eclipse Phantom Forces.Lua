local aimbotenabled = false
local aimbotsmooth = 0
local higlightaimbottarget = false
local aimbotmaxdistance = math.huge
local aimbotprediction = 0
local aimbotteamcheck = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local Camera = workspace.CurrentCamera

local playerhighlight = Instance.new("Highlight",game:GetService("CoreGui"))

function getclosestcharacter()
    local closest = nil
    local lastdistance = math.huge

    for _, charmodel in ipairs(workspace.Players:GetDescendants()) do
        if charmodel:IsA("Model") then
            local nametaggui = charmodel:FindFirstChildWhichIsA("BillboardGui", true)
            if nametaggui and nametaggui:FindFirstChild("PlayerTag") then
                local ptag = nametaggui.PlayerTag
                local distance =
                    (Camera.CFrame.Position - charmodel:GetPivot().Position).Magnitude

                if distance < lastdistance then
                    if aimbotteamcheck then
                        if not ptag.Visible then
                            closest = charmodel
                            lastdistance = distance
                        end
                    else
                        closest = charmodel
                        lastdistance = distance
                    end
                end
            end
        end
    end

    return closest
end

function vec2delta(to, from)
    local x = to.X - from.X
    local y = to.Y - from.Y
    return x, y
end

function aimbotmove()
    local closest = getclosestcharacter()
    if not closest then return end

    if higlightaimbottarget then
        playerhighlight.Adornee = closest
    end

    local pos, onscreen =
        Camera:WorldToViewportPoint(closest:GetPivot().Position)
    if not onscreen then return end

    local smooth = math.max(aimbotsmooth, 1)

    local mouse = UserInputService:GetMouseLocation()
    local pos2d = Vector2.new(pos.X, pos.Y)

    local x, y = vec2delta(pos2d, mouse)
    mousemoverel(x / smooth, y / smooth)
end


--//CHECK THIS
--//////////////////////
local Version = "V1.0.0"

local Changelog = {
	["More Updates Coming Soon!"] = "Check back in a bit for more updates!",
    ["Update V1.0.0"] = "Released the beta version of the script",
}
--//////////////////////
--// CHECK THIS
	
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua"))()

local lua_src = game:HttpGet("https://raw.githubusercontent.com/blizzrblx/Eclipse/refs/heads/main/Eclipse%20Phantom%20Forces.Lua")

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Eclipse | PF",
    Footer = Version,
    Icon = 122940233,
    NotifySide = "Right",
    ToggleKeybind = Enum.KeyCode.RightControl,
})

local DraggableLabel = Library:AddDraggableLabel("Obsidian demo")
DraggableLabel:SetVisible(true)
 
local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

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

if Player.Character then
    local ViewportBox = Tabs.Home:AddLeftGroupbox("Character View")
    local ViewportBox_Viewport = ViewportBox:AddViewport("CharacterViewport", {
	    Object = Player.Character,
	    Camera = Instance.new("Camera"),
	    Interactive = true,
	    AutoFocus = true,
	    Height = 250,
    })  
end

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
local GameName = GameInfoBox:AddLabel("[NEW YEARS UPDATE] Phantom Forces",true)
local PlayersInGame = GameInfoBox:AddLabel(tostring(#Players:GetPlayers()),true)

local TyBox = Tabs.Home:AddLeftGroupbox("Note from Developer")
local TyNote = TyBox:AddLabel("Eclipse is still in early beta, thanks for using and supporting the script!\n\n Made with ♥ by blizz :)",true)

if current_data.script_executions == 0 then PlayerInfoBox_Name:SetText("Welcome to Eclipse, "..Player.Name) end

local AimbotToggleBox = Tabs.Aimbot:AddLeftTabbox("Aimbot")
local AimbotToggleGroup = AimbotToggleBox:AddTab("Toggle")
local AimbotToggleSettingsGroup = AimbotToggleBox:AddTab("Basic Settings")

AimbotToggleGroup:AddToggle("Toggle Aimbot",{
    Text = "Toggle Aimbot",
    Default = false
}):OnChanged(function(State) aimbotenabled = State end)

AimbotToggleSettingsGroup:AddSlider("Smoothness",{
    Text = "Smoothness",
    Default = 0,
    Min = 0,
    Max = 20,
    Rounding = 0,
})

Toggles.Smoothness:OnChanged(function(Value) aimbotsmooth = Value end)

AimbotToggleSettingsGroup:AddToggle("Highlight Target",{
    Text = "Highlight Target",
    Default = false,
}):OnChanged(function(State) higlightaimbottarget = State end)

RunService.RenderStepped:Connect(function(dt)
    PlayersInGame:SetText(tostring(#Players:GetPlayers()).." Players in server")

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

    if aimbotenabled == true then aimbotmove() end
end)
