local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/blizzrblx/Eclipse/refs/heads/main/Eclipse(Mobile%20GUI%20Lib).Lua"))()

local Sidebar = Lib:new()

local noclip = false
local infjump = false
local esp = false
local nametag = false
local speedboost = false
local speedboost_amount = 0

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Camera = workspace.CurrentCamera

local esps = {}

Sidebar:NewToggle({
    Text = "Toggle No-Clip",
    Default = false,
    Callback = function(Enabled)
        noclip = Enabled
    end,
})

Sidebar:NewToggle({
    Text = "Toggle ESP",
    Default = false,
    Callback = function(Enabled)
        esp = Enabled
    end,
})

Sidebar:NewToggle({
    Text = "Toggle Nametags",
    Default = false,
    Callback = function(Enabled)
        nametag = Enabled
    end,
})

Sidebar:NewToggle({
    Text = "Toggle Infinite Jump",
    Default = false,
    Callback = function(Enabled)
        infjump = Enabled
    end,
})

Sidebar:NewToggle({
    Text = "Toggle Speed Boost",
    Default = false,
    Callback = function(Enabled)
        speedboost = Enabled
    end,
})

Sidebar:NewInput({
    Placeholder = 0,
    Numeric = true,
    Text = "Speed Boost Amount",
    Callback = function(Input)
        speedboost_amount = tonumber(Input)
    end
})

function Speedboost(dt)
    if not speedboost then return end

    local char = Player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    local moveDir = hum.MoveDirection
    if moveDir.Magnitude == 0 then
        return
    end

    local targetSpeed = hum.WalkSpeed + speedboost_amount

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

local function removeESP(plr)
    local txt = esps[plr]
    if txt then
        txt:Remove()
        esps[plr] = nil
    end
end

function NameESP()
    local alive = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        alive[plr] = true

        local char = plr.Character
        if not nametag or not char then
            removeESP(plr)
            continue
        end

        local pos = char:GetPivot().Position + Vector3.new(0, 3, 0)
        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)

        if not onScreen then
            removeESP(plr)
            continue
        end

        if not esps[plr] then
            local txt = Drawing.new("Text")
            txt.Center = true
            txt.Outline = true
            txt.Size = 16
            esps[plr] = txt
        end

        local txt = esps[plr]
        txt.Text = plr.Name
        txt.Position = Vector2.new(screenPos.X, screenPos.Y)
        txt.Visible = true

        if plr.Team and plr.Team.Name == "Police" then
            txt.Color = plr.Team.TeamColor.Color
        end
    end
    for plr in pairs(esps) do
        if not alive[plr] then
            removeESP(plr)
        end
    end
end

RunService.RenderStepped:Connect(function(dt)
        if Player.Character then
            for I,v in pairs(Player.Character:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = not noclip end
            end
        end

    Speedboost(dt)
    NameESP()

    if esp then
        for i,player in pairs(Players:GetPlayers()) do
            if player.Character then
                if not player.Character:FindFirstChild("OWESP") then
                    local OWESP = Instance.new("Highlight")
                    OWESP.Parent = player.Character
                    OWESP.Name = "OWESP"

                    if player.Team then OWESP.FillColor = player.Team.TeamColor.Color else OWESP.FillColor = Color3.fromRGB(205,0,0) end
                else
                    local OWESP = player.Character:FindFirstChild("OWESP")

                    if player.Team then OWESP.FillColor = player.Team.TeamColor.Color else OWESP.FillColor = Color3.fromRGB(205,0,0) end
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infjump then
        if Player.Character then
            Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
