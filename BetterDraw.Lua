local BetterDraw = {}
BetterDraw.Active = true
BetterDraw.__Nametags = {}
BetterDraw.__Alive = {}
BetterDraw.__AttachedPlayers = {}
BetterDraw.__OnScreen = {}

BetterDraw.__index = BetterDraw

function BetterDraw:NewNametag(AttachedPlayer)
    local BaseProps = {
        Visible = false,
        Remove = function() end,
        Color = Color3.fromRGB(255,255,255),
        Text = "No Text Added",
        Transparency = 1,
        Size = 1,
        Center = true,
        Outline = true,
        OutlineColor  = Color3.fromRGB(0,0,0),
        Position = Vector2.new(0.5,0.5),
        Font = 1,
    }

    local draw = Drawing.new("Text")
    draw.Visible = BaseProps.Visible
    draw.Color = BaseProps.Color
    draw.Text = BaseProps.Text
    draw.Size = BaseProps.Size
    draw.Center = BaseProps.Center
    draw.Outline = BaseProps.Outline
    draw.OutlineColor = BaseProps.OutlineColor
    draw.Position = BaseProps.Position
    draw.Transparency = BaseProps.Transparency
    draw.Font = BaseProps.Font

    BetterDraw.__Nametags[draw] = draw
    BetterDraw.__AttachedPlayers[draw] = AttachedPlayer

    return Draw
end

function BetterDraw:Toggle(State)
    BetterDraw.Active = State
end

while BetterDraw.Active then
    for _,plr in pairs(game:GetService("Players"):GetPlayers())
        BetterDraw.__Alive[plr.Name] = plr
    end

    for _,plr in pairs(BetterDraw.__Alive) do
        if not game:GetService("Players"):FindFirstChild(plr) then
            BetterDraw.__Alive[plr.Name] = nil
        end
    end

    for draw,plr in pairs(BetterDraw.__AttachedPlayers) do
        if BetterDraw.__Alive[plr.Name] then
            local Character = plr.Character or plr.CharacterAdded:Wait()
            
            local Root = Character.HumanoidRootPart

            if Root then
                local ScreenPos,OnScreen = workspace.CurrentCamera:WorldToViewportPoint(Root.Position)

                if OnScreen then
                    draw.Position = ScreenPos
                    draw.Text = plr.Name
                else
                    BetterDraw.__OnScreen[draw] = false
                    BetterDraw.__Nametags[draw] = nil
                    draw:Remove()
                end
            else

            end
        else
            if BetterDraw.__Nametags[draw] then
                BetterDraw.__Nametags[draw] = nil
            end
        end
    end
end
return BetterDraw
