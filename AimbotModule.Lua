local AimbotModule = {}
AimbotModule.CurrentKeybind = Enum.UserInputType.MouseButton2
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
AimbotModule.DeadCheck = false
AimbotModule.BHop = false
AimbotModule.SpeedBoostEnabled = false
AimbotModule.SpeedBoost = 0

local weaponSkins = {
    ["Bow"] = {"Compound Bow", "Raven Bow", "Key Bow", "Bat Bow", "Dream Bow", "Frostbite Bow", "Glorious Bow"},
    ["Assault Rifle"] = {"AK-47", "AUG", "AKEY-47", "Gingerbread AUG", "Tommy Gun", "Boneclaw Rifle", "Glorious Assault Rifle", "Phoenix Rifle", "10B Visits"},
    ["Chainsaw"] = {"Blobsaw", "Handsaws", "Buzzsaw", "Festive Buzzsaw", "Mega Drill", "Glorious Chainsaw"},
    ["RPG"] = {"Nuke Launcher", "RPKEY", "Spaceship Launcher", "Firework Launcher" "Pumpkin Launcher" "Squid Launcher", "Glorious RPG", "Pencil Launcher"},
    ["Burst Rifle"] = {"Aqua Burst", "Electro Rifle", "Keyst Rifle", "FAMAS", "Pixel Burst", "Glorious Burst Rifle", "Pine Burst", "Spectral Burst"},
    ["Exogun"] = {"Singularity", "Wondergun", "Repulsor", "Exogourd", "Ray Gun", "Glorious Exogun", "Midnight Festive Exogun"},
    ["Fists"] = {"Boxing Gloves", "Brass Knuckles", "Fists of Hurt", "Festive Fists", "Glorious Fists", "Pumpkin Claws"},
    ["Energy Pistols"] = {"Soul Pistols", "Apex Pistols", "Void Pistols", "Hacker Pistols", "Hydro Pistols", "New Year Energy Pistols", "Glorious Energy Pistols"}
    ["Flamethrower"] = {"Lamethrower", "Pixel Flamethrower", "Glitterthrower", "Snowblower", "Glorious Flamethrower"},
    ["Flare Gun"] = {"Dynamite Gun", "Firework Gun", "Banana Flare", "Vexed Flare Gun", "Glorious Flare Gun", "Wrapped Flare Gun"},
    ["Freeze Ray"] = {"Bubble Ray", "Temporal Ray", "Spider Ray", "Gum Ray", "Glorious Freeze Ray", "Wrapped Freeze Ray"},
    ["Grenade"] = {"Water Balloon", "Whoopee Cushion", "Keynade", "Soul Grenade", "Jingle Grenade", "Dynamite", "Frozen Grenade", "Glorious Grenade"},
    ["Grenade Launcher"] = {"Swashbuckler", "Uranium Launcher", "Skull Launcher", "Gearnade Launcher", "Snowball Launcher", "Glorious Grenade Launcher"},
    ["Handgun"] = {"Blaster", "Hand Gun", "Pixel Handgun", "Gingerbread Handgun", "Glorious Handgun", "Gumball Handgun", "Pumpkin Handgun", "Towerstone Handgun", "Warp Handgun"},
    ["Katana"] = {"Lightning Bolt", "Saber", "Arch Katana", "Crystal Katana", "Keytana", "Pixel Katana", "Devil's Trident", "New Year Katana", "Stellar Katana", "Glorious Katana"},
    ["Minigun"] = {"Lasergun 3000", "Pixel Minigun", "Fighter Jet", "Glorious Minigun", "Pumpkin Minigun", "Wrapped Minigun"},
    ["Paintball Gun"] = {"Boba Gun", "Slime Gun", "Brain Gun", "Snowball Gun", "Glorious Paintball Gun", "Ketchup Gun"},
    ["Revolver"] = {"Sheriff", "Keyvolver", "Peppergun", "Peppermint Sheriff", "Boneclaw Revolver", "Desert Eagle", "Glorious Revolver"},
    ["Slingshot"] = {"Goalpost", "Stick", "Harp", "Boneshot", "Reindeer Slingshot", "Glorious Slingshot"},
    ["Subspace Tripmine"] = {"Don't Press", "Spring", "Dev-in-the-Box", "DIY Tripmine", "Glorious Subspace Tripmine", "Trick or Treat"},
    ["Uzi"] = {"Electro Uzi", "Water Uzi", "Keyzi", "Money Gun", "Demon Uzi", "Glorious Uzi", "Pine Uzi"},
    ["Sniper"] = {"Pixel Sniper", "Hyper Sniper", "Keyper", "Event Horizion", "Gingerbread Sniper", "Eyething Sniper", "Glorious Sniper"},
    ["Knife"] = {"Karambit", "Chancla", "Keylisong", "Keyrambit", "Balisong", "Candy Cane", "Glorious Knife", "Machete"}}

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
                        if AimbotModule.DeadCheck then
                            if char:FindFirstChild("Humanoid") and char:FindFirstChild("Humanoid").Health > 0 then
                                table.insert(Chars, plr)
                            end
                        else
                            table.insert(Chars, plr)
                        end
                    end
                else
                    if AimbotModule.DeadCheck then
                        if char:FindFirstChild("Humanoid") and char:FindFirstChild("Humanoid").Health > 0 then
                            table.insert(Chars, plr)
                        end
                    else
                        table.insert(Chars, plr)
                    end
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

function SetSpeed(dt)
    if not AimbotModule.SpeedBoostEnabled then return end

    local char = Player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    local moveDir = hum.MoveDirection
    if moveDir.Magnitude == 0 then
        return
    end

    local targetSpeed = hum.WalkSpeed + AimbotModule.SpeedBoost

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

function GetSwapped(NormalWeapon,Skin)
    local FoundWeapon = weaponSkins[NormalWeapon]
    if not FoundWeapon then return end
    local FoundSkin = FoundWeapon[Skin]
    if not FoundSkin then return end

    local ViewModels = Player.PlayerScripts.Assets.ViewModels

    for I, FoundVM in ipairs(ViewModels:GetDescendants()) do
        local Is_Model = (typeof(FoundVM) == "Model")
        if Is_Model then
            return {
                ["VM"] = FoundVM,
                ["Weapon"] = NormalWeapon
            }
        end
    end
    return nil
end

function ApplySkin(VMtbl)
    local Vm = VMtbl.VM
    local Weapon = VMtbl.Weapon

    local ViewModels = workspace.ViewModels

    local FirstPerson = ViewModels.FirstPerson

    local Model = FirstPerson:FindFirstChildOfClass("Model")

    if string.find(Model.Name, Player.Name) then
        local Visual = Model.ItemVisual

        Weapon:PivotTo(Visual:GetPivot())
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

function AimbotModule:ToggleTriggerbot(Enabled)
    AimbotModule.TBEnabled = Enabled
end

function AimbotModule:ToggleRGB(Enabled)
    AimbotModule.RGBEnabled = Enabled
end

function AimbotModule:SetKeybind(Key)
    AimbotModule.CurrentKeybind = Key
end

function AimbotModule:ToggleDeadCheck(Enabled)
    AimbotModule.DeadCheck = Enabled
end

function AimbotModule:ToggleBHop(Enabled)
    AimbotModule.BHop = Enabled
end

UIS.InputBegan:Connect(function(Input,GameProcessed)
    if GameProcessed then return end
    if Input.UserInputType == AimbotModule.CurrentKeybind or Input.KeyCode == AimbotModule.CurrentKeybind then
        AimbotModule.Active = true
    end
end)

UIS.InputEnded:Connect(function(Input,GameProcessed)
    if GameProcessed then return end
    if Input.UserInputType == AimbotModule.CurrentKeybind or Input.KeyCode == AimbotModule.CurrentKeybind then
        AimbotModule.Active = false
    end
end)

RunService.RenderStepped:Connect(function(dt)
    SetClosest()
    LookAtTarget()
    TriggerbotCheck()
    UpdateNameESP()
    SetSpeed(dt)

    local t = 5
    local hue = tick() % t / t
    AimbotModule.RGBColor = Color3.fromHSV(hue, 1, 1)

    if not AimbotModule.BHop then
        return
    end

    local char = Player.Character
    if not char then
        return
    end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    if humanoid.FloorMaterial ~= Enum.Material.Air then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

return AimbotModule
