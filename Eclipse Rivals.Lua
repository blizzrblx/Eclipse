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
		[3] = "Check back later for more updates!",
		[4] = Color3.fromRGB(255,255,255)
	},
	{
		[1] = 1,
		[2] = "V1.0.0",
		[3] = "Released the script",
		[4] = Color3.fromRGB(255,255,255)
	}
}

table.sort(changelog,function(a,b) 
	return a[1] > b[1]
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
ErrorLogsLabel.TextSize = 18
ErrorLogsLabel.TextWrapped = true
ErrorLogsLabel.TextXAlignment = Enum.TextXAlignment.CurrentCamera
ErrorLogsLabel.TextYAlignment = Enum.TextYAlignment.Top

local ChangelogScroller = Instance.new("ScrollingFrame")
ChangelogScroller.BackgroundTransparency = 1,
ChangelogScroller.BorderSizePixel = 0
ChangelogScroller.CanvasSize = UDim2.fromScale(1,1)
ChangelogScroller.ScrollDirection = Enum.ScrollDirection.Vertical

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

for _,updtable in pair(changelog) do
	local updvalue,updname,updcontent,updtextcolor = updtable[1], updtable[2], updtable[3], updtable[4]

	ChangelogLabel.Text = ChangelogLabel.Text..updname.."\n\n"..updcontent

	ChangelogScroller.CanvasSize = UDim2.fromScale(1,ChangelogScroller.CanvasSize.Y + 0.2)
end

HomeRightGroupBox:AddLabel("Eclipse is running on: "..identifyexecutor(),true)
HomeRightGroupBox:AddLabel("The current version is: "..version,true)

local ErrorModule = {}

function ErrorModule:newError(Settings:{
	Title:string,
	Message:string,
	Status:string,
	}

	if Settings.Status == "Error" then
		ErrorLogsLabel.Text = ErrorLogsLabel.Text.."\n\n"..Settings.Title..'\n\n<font color="rgb(225,0,0)">'..Settings.Message.."</font>".."TIME:"..os.date()
			Library:Notify({
    	Title = "Eclipse",
   		Description = "Error!",
    	Time = 4,
	})
	elseif Settings.Status == "Warning" then
		ErrorLogsLabel.Text = ErrorLogsLabel.Text.."\n\n"..Settings.Title..'\n\n<font color="rgb(255, 230, 0)">['..Settings.Message.."]</font>".."TIME:"..os.date()
	else
		ErrorLogsLabel.Text = ErrorLogsLabel.Text.."\n\n"..Settings.Title..'\n\n<font color="rgb(255, 255, 255)">'..Settings.Message.."</font>".."TIME:"..os.date()
	end
end)

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

RunService.RenderStepped:Connect(function()
	PlayersInServerLabel:SetText("Players in server: "..tostring(#Players:GetPlayers()),true)
	local FrameTimer = tick()
	local FrameCounter = 0
	local FPS = 60
    FrameCounter += 1
 
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
 
    DraggableLabel:SetText(('Eclipse Rivals | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)
