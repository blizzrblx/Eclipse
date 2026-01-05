local AimbotModule = {}
AimbotModule.CurrentTarget = nil
AimbotModule.CurrentCharacter = nil
AimbotModule.Enabled = false
AimbotModule.Active = false
AimbotModule.MaxTrackingDistance = 500
AimbotModule.CurrentSortFn = nil
AimbotModule.Smoothness = 0
AimbotModule.Prediction = 0.05
AimbotModule.TBEnabled = false
AimbotModule.TBTarget = "Head"
AimbotModule.NametagEnabled = false
AimbotModule.NametagInstances = {}
AimbotModule.RGBEnabled = false
AimbotModule.RGBColor = nil

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

function GetService(ServiceName)
    assert(type(ServiceName) == "string","BlizzAimbotV1: Incorrect type")
    return cloneref(game:GetService(ServiceName))
end

local Players = GetService("Players")
local UIS = GetService("UserInputService")
local RunService = GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

function FilterCharacters()
    local Chars = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                if AimbotModule.CurrentSortFn then
                    if AimbotModule.CurrentSortFn(Player, plr) then
                        table.insert(Chars, plr)
                    end
                else
                    table.insert(Chars, plr)
                end
            end
        end
    end

    return Chars
end

function GetClosestCharacter()
    local character = Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closest = nil
    local closestDistance = math.huge

    for _, plr in ipairs(FilterCharacters()) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if hrp then
            local dist = (hrp.Position - root.Position).Magnitude
            if dist <= AimbotModule.MaxTrackingDistance and dist < closestDistance then
                closestDistance = dist
                closest = char
            end
        end
    end

    return closest
end

function SetClosest()
    local Closest = GetClosestCharacter()

    if Closest then
        AimbotModule.CurrentCharacter = Closest

        local Highlight = workspace:FindFirstChild("BlizzAimbot_Target")
        Highlight.Adornee = Closest
        Highlight.Enabled = true
        if Closest:FindFirstChild("Head") then
            AimbotModule.CurrentTarget = Closest:FindFirstChild("Head")
        else
            AimbotModule.CurrentTarget = Closest.HumanoidRootPart
        end
    end
end

function LookAtTarget()
    if not (AimbotModule.Enabled and AimbotModule.Active) then return end
    if not AimbotModule.CurrentTarget then return end

    local targetPart = AimbotModule.CurrentTarget

    local predictionTime = AimbotModule.Prediction

    local velocity = targetPart.AssemblyLinearVelocity
    local predictedPosition =
        targetPart.Position + (velocity * predictionTime)

    local screenPos, onScreen =
        Camera:WorldToViewportPoint(predictedPosition)

    if not onScreen then return end

    local mousePos = UIS:GetMouseLocation()

    local deltaX = screenPos.X - mousePos.X
    local deltaY = screenPos.Y - mousePos.Y

    local smooth = math.max(AimbotModule.Smoothness, 1)

    deltaX /= smooth
    deltaY /= smooth

    mousemoverel(deltaX, deltaY)
end

function TriggerbotCheck()
    if not AimbotModule.TBEnabled then return end

    local Target = Mouse.Target

    if Target then
        if Target.Name == AimbotModule.TBTarget and Players:GetPlayerFromCharacter(Target.Parent) then mouse1click() end
    end
end

function RemoveNametag(plr)
    local nametag = AimbotModule.NametagInstances[plr]

    if nametag then nametag:Remove() end
end

function SetESPTag()
    if not AimbotModule.NametagEnabled then return end

    local alive = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if not hrp then
                RemoveNametag(plr)
                continue
            end

            alive[plr] = true

            local screenPos, visible =
                Camera:WorldToViewportPoint(hrp.Position)

            if not visible then
                RemoveNametag(plr)
                continue
            end

            if not AimbotModule.NametagInstances[plr] then
                local tag = Drawing.new("Text")
                tag.Center = true
                tag.Outline = true
                tag.Size = 16
                tag.Visible = true
                AimbotModule.NametagInstances[plr] = tag
            end

            local tag = AimbotModule.NametagInstances[plr]
            tag.Text = plr.DisplayName
            tag.Position = Vector2.new(screenPos.X, screenPos.Y)
            tag.Color = AimbotModule.RGBEnabled and AimbotModule.RGBColor
                or Color3.fromRGB(205, 0, 0)
        end
    end

    for plr in pairs(AimbotModule.NametagInstances) do
        if not alive[plr] then
            RemoveNametag(plr)
        end
    end
end


AimbotModule.Init = function()
    AimbotModule.Enabled = false
    
    local TargetHighlight = Instance.new("Highlight",workspace)
    TargetHighlight.Name = "BlizzAimbot_Target"
    TargetHighlight.Enabled = false
end

function AimbotModule:SetSort(fn)
    if fn then 
        if type(fn) == "string" then
            if fn == "Arsenal" then
                AimbotModule.CurrentSortFn = function(Local,Other)
                    return Other.Team.Name ~= Local.Team.Name
                end
            elseif fn = "Jailbreak" or "JB" then
                AimbotModule.CurrentSortFn = function(Local,Other)
                    return Other.Team.Name ~= Local.Team.Name
                end
            end
        else
            AimbotModule.CurrentSortFn = fn
        end
    else
        error("No Function given")
    end
end

function AimbotModule:SetSmooth(Amount)
    AimbotModule.Smoothness = Amount
end

function AimbotModule:SetMaxDistance(Amount)
    AimbotModule.MaxTrackingDistance = Amount
end

function AimbotModule:SetPrediction(Amount)
    AimbotModule.Prediction = Amount
end

function AimbotModule:Toggle(Enabled)
    AimbotModule.Enabled = Enabled
end

function AimbotModule:Triggerbot(Enabled)
    AimbotModule.TBEnabled = Enabled
end

function AimbotModule:Nametag(Enabled)
    AimbotModule.NametagEnabled = Enabled
end

function AimbotModule:RGB(Enabled)
    AimbotModule.RGBEnabled = Enabled
end

UIS.InputBegan:Connect(function(Input,GameProcessed)
    if GameProcessed then return end
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotModule.Active = true
    end
end)

UIS.InputEnded:Connect(function(Input,GameProcessed)
    if GameProcessed then return end
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotModule.Active = false
    end
end)

RunService.RenderStepped:Connect(function()
    SetClosest()
    LookAtTarget()
    TriggerbotCheck()
	SetESPTag()

    local t = 5;

	local hue = tick() % t / t
	local color = Color3.fromHSV(hue, 1, 1)
    AimbotModule.RGBColor = color
end)

return AimbotModule
