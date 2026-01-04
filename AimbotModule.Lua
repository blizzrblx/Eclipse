local AimbotModule = {}
AimbotModule.CurrentTarget = nil
AimbotModule.CurrentCharacter = nil
AimbotModule.Enabled = false
AimbotModule.Active = false
AimbotModule.MaxTrackingDistance = 500
AimbotModule.CurrentSortFn = nil
AimbotModule.Smoothness = 0

getgenv().BlizzAimbotActive = false

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
        if Closest:FindFirstChild("Head") then
            AimbotModule.CurrentTarget = Closest:FindFirstChild("Head")
        else
            AimbotModule.CurrentTarget = Closest.HumanoidRootPart
        end
    end
end

function LookAtTarget()
    if AimbotModule.CurrentTarget == nil then return end
    if AimbotModule.CurrentCharacter == nil then return end

    local screenPos,onScreen = Camera:WorldToViewportPoint(AimbotModule.CurrentTarget.Position)

    local targetX,targetY = screenPos.X,screenPos.Y

    local deltaX = targetX - UIS:GetMouseLocation().X
    local deltaY = targetY - UIS:GetMouseLocation().Y

    local predictionX,predictionY = (deltaX + AimbotModule.CurrentTarget.Velocity.Z), (deltaY + AimbotModule.CurrentTarget.Velocity.Y)

    if onScreen then
        if AimbotModule.Enabled and AimbotModule.Active then
            mousemoverel(predictionX:Lerp(AimbotModule.Smoothness),predictionY:Lerp(AimbotModule.Smoothness)
        end
    end
end

AimbotModule.Init = function()
    getgenv().BlizzAimbotActive = true
    AimbotModule.Enabled = true
    print("Running")
end

function AimbotModule:SetSort(fn)
    if fn then
        AimbotModule.CurrentSortFn = fn
    else
        error("No Function given")
    end
end

function AimbotModule:SetSmooth(Amount)
    AimbotModule.Smoothness = Amount
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
