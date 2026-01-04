local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer

local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Options = Library.Options

local ESPEnabled = false
local TeamESPEnabled = false
local ESPNameEnabled = false
local ESPNameTeamColor = false
local ESPLineEnabled = false
local ESPLineSmoothOrgin = false
local ESPLineTeamColor = false
local ESPLineCentered = false
local ESPColor = Color3.fromRGB(255, 0, 0)

local JumpBoostEnabled = false
local JumpHeightBoost = 0

local SpeedBoostEnabled = false
local SpeedBoost = 0

local InfJumpEnabled = false

local ESPNameInstances = {}
local ESPLineInstances = {}

local function GetCharacters(filterSelf)
    local chars = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if not filterSelf or plr ~= Player then
                table.insert(chars, plr.Character)
            end
        end
    end
    return chars
end

function GetPlayers(filterSelf)
    local plrs = {}
    for _,plr in ipairs(Players:GetPlayers()) do
        if not filterSelf or plr ~= Player then
            table.insert(plrs,plr)
        end
    end

    return plrs
end

local function UpdateESP()
    for _, char in ipairs(GetCharacters(true)) do
        local plr = Players:GetPlayerFromCharacter(char)
        if not plr then continue end

        local esp = char:FindFirstChild("Eclipse_ESP")

        if ESPEnabled then
            if not esp then
                esp = Instance.new("Highlight")
                esp.Name = "Eclipse_ESP"
                esp.Parent = char
                esp.FillTransparency = 0.5
                esp.OutlineTransparency = 0
            end

            if TeamESPEnabled and plr.Team then
                if plr.Team.Name == "Police" then
                    esp.FillColor = Color3.fromRGB(33, 33, 255)
                elseif plr.Team.Name == "Prisoner" then
                    esp.FillColor = Color3.fromRGB(255, 129, 87)
                else
                    esp.FillColor = Color3.fromRGB(226, 1, 1)
                end
            else
                esp.FillColor = ESPColor
            end
        else
            if esp then esp:Destroy() end
        end
    end
end

local function removeESP(plr)
    local txt = ESPNameInstances[plr]
    if txt then
        txt:Remove()
        ESPNameInstances[plr] = nil
    end
end

local function removeLine(plr)
    local line = ESPLineInstances[plr]
    if line then
        line:Remove()
        ESPLineInstances[plr] = nil
    end
end

local function UpdateNameESP()
    local alive = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        alive[plr] = true

        local char = plr.Character
        if not ESPNameEnabled or not char then
            removeESP(plr)
            continue
        end

        local pos = char:GetPivot().Position + Vector3.new(0, 3, 0)
        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)

        if not onScreen then
            removeESP(plr)
            continue
        end

        if not ESPNameInstances[plr] then
            local txt = Drawing.new("Text")
            txt.Center = true
            txt.Outline = true
            txt.Size = 16
            ESPNameInstances[plr] = txt
        end

        local txt = ESPNameInstances[plr]
        txt.Text = plr.Name
        txt.Position = Vector2.new(screenPos.X, screenPos.Y)
        txt.Visible = true

        if ESPNameTeamColor then
            if plr.Team and plr.Team.Name == "Police" then
                txt.Color = Color3.fromRGB(33, 33, 255)
            elseif plr.Team and plr.Team.Name == "Prisoner" then
                txt.Color = Color3.fromRGB(255, 129, 87)
            else
                txt.Color = Color3.fromRGB(226, 1, 1)
            end
        else
            txt.Color = ESPColor
        end
    end
    for plr in pairs(ESPNameInstances) do
        if not alive[plr] then
            removeESP(plr)
        end
    end
end

function UpdateLineESP()
    local alive = {}

    for _, plr in ipairs(GetPlayers(true)) do
        alive[plr] = true

        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if not ESPLineEnabled or not root then
            removeLine(plr)
            continue
        end

        local screenPos, onScreen =
            Camera:WorldToViewportPoint(root.Position)

        if not onScreen then
            removeLine(plr)
            continue
        end

        local mousePos = UIS:GetMouseLocation()
        local origin = Vector2.new(mousePos.X, mousePos.Y)

        if ESPLineCentered then
            origin = Vector2.new((Camera.ViewportSize / 2), (Camera.ViewportSize / 2))
        end

        if not ESPLineInstances[plr] then
            local line = Drawing.new("Line")
            line.Transparency = 1
            line.Thickness = 2
            line.Color = ESPColor
            line.Visible = true
            line.From = origin
            ESPLineInstances[plr] = line
        end

        local line = ESPLineInstances[plr]
        
        if ESPLineSmoothOrgin then
            line.From = line.From:Lerp(origin,0.25)
        else
            line.From = origin
        end
        line.To = Vector2.new(screenPos.X, screenPos.Y)
        line.Visible = true

        if ESPLineTeamColor then
            if plr.Team and plr.Team.Name == "Police" then
                line.Color = Color3.fromRGB(33, 33, 255)
            elseif plr.Team and plr.Team.Name == "Prisoner" then
                line.Color = Color3.fromRGB(255, 129, 87)
            else
                line.Color = Color3.fromRGB(226, 1, 1)
            end
        else
            line.Color = ESPColor
        end
    end

    for plr in pairs(ESPLineInstances) do
        if not alive[plr] then
            removeLine(plr)
        end
    end
end

function SetJump()
    if JumpBoostEnabled == false then return end

    local hrp = Player.Character.HumanoidRootPart
    local hum = Player.Character.Humanoid

    local vec = Vector3.new(hrp.Velocity.X,JumpHeightBoost,hrp.Velocity.Z)
    hrp.Velocity = vec
end


function SetSpeed(dt)
    if not SpeedBoostEnabled then return end

    local char = Player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if hum.FloorMaterial == Enum.Material.Air then
        return
    end

    local moveDir = hum.MoveDirection
    if moveDir.Magnitude == 0 then
        return
    end

    local targetSpeed = hum.WalkSpeed + SpeedBoost

    local horizontalVel = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)

    local desiredVel = moveDir * targetSpeed

    local accel = 12
    local newVel = horizontalVel:Lerp(desiredVel, math.clamp(accel * dt, 0, 1))

    hrp.Velocity = Vector3.new(
        newVel.X,
        hrp.Velocity.Y,
        newVel.Z
    )
end

UIS.JumpRequest:Connect(function()
    if Player.Character.Humanoid.Jump == false and InfJumpEnabled == false then
        SetJump()
    elseif InfJumpEnabled == true then
        SetJump()
    end
end)

UIS.JumpRequest:Connect(function()
    if InfJumpEnabled == true then Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

local Window = Library:CreateWindow({
    Title = "Eclipse | Jailbreak",
    SubTitle = "by blizz",
    TabWidth = 160,
    Size = UDim2.fromOffset(650, 650),
    Resize = true,
    MinSize = Vector2.new(380, 380),
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:CreateTab({Title = "Player",Icon = "user-round-pen"}),
    ESP = Window:CreateTab({ Title = "Visuals", Icon = "eye" }),
    Settings = Window:CreateTab({ Title = "Settings", Icon = "settings" }),
}

local JumpSection = Tabs.Main:AddSection("Jump")

JumpSection:CreateToggle("JumpBoostToggle", { Title = "Toggle Jump Boost", Default = false})
    :OnChanged(function() JumpBoostEnabled = Options.JumpBoostToggle.Value end)

JumpSection:CreateInput("JumpBoostInput", {
    Title = "Jump Boost Amount", Default = "0", Placeholder = "0", Numeric = true, Finished = false,
    Callback = function(Value)
        JumpHeightBoost = tonumber(Value)
    end
})

JumpSection:CreateToggle("InfJumpToggle", { Title = "Toggle Infinite Jump", Default = false})
    :OnChanged(function() InfJumpEnabled = Options.InfJumpToggle.Value end)

local SpeedSection = Tabs.Main:AddSection("Speed")

SpeedSection:CreateToggle("SpeedBoostToggle", { Title = "Toggle Speed Boost", Default = false})
    :OnChanged(function() SpeedBoostEnabled = Options.SpeedBoostToggle.Value end)

SpeedSection:CreateInput("SpeedBoostInput", {
    Title = "Speed Boost Amount", Default = "0", Placeholder = "0", Numeric = true, Finished = false,
    Callback = function(Value)
        SpeedBoost = tonumber(Value)
    end
})

local HighlightSection = Tabs.ESP:AddSection("Highlight ESP")

HighlightSection:CreateToggle("ESPToggle", { Title = "Toggle ESP", Default = false })
    :OnChanged(function() ESPEnabled = Options.ESPToggle.Value end)

HighlightSection:CreateColorpicker("ESPColorpicker", {
    Title = "ESP Color",
    Default = ESPColor
}):OnChanged(function()
    ESPColor = Options.ESPColorpicker.Value
end)

HighlightSection:CreateToggle("ESPTeamToggle", { Title = "Team Colors", Default = false })
    :OnChanged(function() TeamESPEnabled = Options.ESPTeamToggle.Value end)

local NameSection = Tabs.ESP:AddSection("Nametag ESP")

NameSection:CreateToggle("ESPNameToggle", { Title = "Name Tags", Default = false })
    :OnChanged(function() ESPNameEnabled = Options.ESPNameToggle.Value end)

NameSection:CreateToggle("ESPNameTeamToggle", { Title = "Name Tag Team Color", Default = false })
    :OnChanged(function() ESPNameTeamColor = Options.ESPNameTeamToggle.Value end)

local LineSection = Tabs.ESP:AddSection("Tracer ESP")

LineSection:CreateToggle("ESPLineToggle", { Title = "ESP Tracers", Default = false })
    :OnChanged(function() ESPLineEnabled = Options.ESPLineToggle.Value end)

LineSection:CreateToggle("ESPLineSmoothOrginToggle", { Title = "ESP Tracer Smoothing", Default = false })
    :OnChanged(function() ESPLineSmoothOrgin = Options.ESPLineSmoothOrginToggle.Value end)

LineSection:CreateToggle("ESPLineCenteredToggle", { Title = "ESP Tracer Smoothing", Default = false })
    :OnChanged(function() ESPLineCentered = Options.ESPLineCenteredToggle.Value end)

LineSection:CreateToggle("ESPLineTeamToggle", { Title = "ESP Tracer Team Color", Default = false })
    :OnChanged(function() ESPLineTeamColor = Options.ESPLineTeamToggle.Value end)

RunService.RenderStepped:Connect(function(dt)
    UpdateESP()
    UpdateNameESP()
    UpdateLineESP()
    SetSpeed(dt)
end)

SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)

InterfaceManager:SetFolder("EclipseHub")
SaveManager:SetFolder("EclipseHub/jailbreak")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

