local AimbotModule = {}
AimbotModule.CurrentTarget = nil
AimbotModule.CurrentCharacter = nil
AimbotModule.Enabled = false
AimbotModule.Active = false
AimbotModule.MaxTrackingDistance = 500
AimbotModule.CurrentSortFn = nil
AimbotModule.Smoothness = 0
AimbotModule.Prediction = 0.05

if not getgenv().BlizzAimbotActive then
    getgenv().BlizzAimbotActive = false
end

if getgenv().BlizzAimbotActive == true then return end

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

AimbotModule.Init = function()
    getgenv().BlizzAimbotActive = true
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
            elseif fn == "Jailbreak" or "JB" then
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
end)

return AimbotModule
