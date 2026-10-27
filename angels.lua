-- Angels and Dimitris Hc | MOBILE | Full Uncompressed
if game:GetService("CoreGui"):FindFirstChild("AngelsAndDimitrisHc") then
    game:GetService("CoreGui"):FindFirstChild("AngelsAndDimitrisHc"):Destroy()
end

local P = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS2 = game:GetService("ReplicatedStorage")
local HS = game:GetService("HttpService")
local LP = P.LocalPlayer
local cam = workspace.CurrentCamera
local mouse = LP:GetMouse()

local g = getgenv and getgenv() or _G
g.AngelsHc = g.AngelsHc or {}
local c = g.AngelsHc
c.Enabled = c.Enabled or false
c.FOVRadius = c.FOVRadius or 150
c.HitPart = c.HitPart or "Head"
c.TeamCheck = c.TeamCheck or false
c.RequireTool = c.RequireTool == nil and true or c.RequireTool
c.KnockCheck = c.KnockCheck == nil and true or c.KnockCheck
c.WallCheck = c.WallCheck or false
c.ClosestPart = c.ClosestPart or false
c.MaxDist = c.MaxDist or 1000
c.AutoPred = false
c.PredStrength = c.PredStrength or 0.15
c.HitChance = c.HitChance or 100
c.FovEnabled = c.FovEnabled == nil and true or c.FovEnabled
c.FovFilled = c.FovFilled or false
c.FovThickness = c.FovThickness or 1.5
c.SkinChanger = c.SkinChanger or { Enabled = false, Skins = {}, Knife = "" }
c.BulletBeams = c.BulletBeams or { Enabled = false, Selected = "Beta" }
c.WalkSpeed = c.WalkSpeed or { Enabled = false, Value = 16, Default = 16 }
c.ToolGrabber = c.ToolGrabber or { Flintlock = false, Balloon = false, Active = false }

local parts = {"Head","UpperTorso","HumanoidRootPart","LowerTorso","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"}

local function ref()
    local vp = cam.ViewportSize
    return Vector2.new(vp.X/2, vp.Y/2)
end
local function knocked(ch)
    local be = ch and ch:FindFirstChild("BodyEffects")
    local ko = be and (be:FindFirstChild("K.O") or be:FindFirstChild("KO"))
    return ko and ko.Value
end
local function holding()
    if not c.RequireTool then return true end
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Tool") ~= nil
end
local function visible(part)
    if not c.WallCheck then return true end
    local ch = LP.Character
    local origin = cam.CFrame.Position
    if ch then
        local head = ch:FindFirstChild("Head")
        if head then origin = head.Position end
    end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances = {ch, cam}
    local r = workspace:Raycast(origin, part.Position - origin, rp)
    return not r or r.Instance:IsDescendantOf(part.Parent)
end
local function aimPos(part)
    if c.AutoPred then
        local v = part.AssemblyLinearVelocity or part.Velocity or Vector3.new()
        if v.Magnitude < 0.05 then return part.Position end
        return part.Position + v * c.PredStrength
    end
    return part.Position
end
local function closest(ch)
    local best, bd = nil, math.huge
    local r = ref()
    for _, n in ipairs(parts) do
        local p = ch:FindFirstChild(n)
        if p then
            local sp, on = cam:WorldToViewportPoint(p.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - r).Magnitude
                if d < bd then bd = d; best = p end
            end
        end
    end
    return best
end
local function getPart(ch)
    if c.ClosestPart then
        return closest(ch) or ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
    end
    return ch:FindFirstChild(c.HitPart) or ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
end

local function target()
    if not c.Enabled or (c.RequireTool and not holding()) then return nil end
    local bestPart, bd = nil, c.FOVRadius
    local r = ref()
    for _, plr in ipairs(P:GetPlayers()) do
        if plr ~= LP then
            local ch = plr.Character
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and not (c.KnockCheck and knocked(ch)) and not (c.TeamCheck and plr.Team == LP.Team) then
                    local hrp = ch:FindFirstChild("HumanoidRootPart")
                    if not hrp or (hrp.Position - cam.CFrame.Position).Magnitude <= c.MaxDist then
                        local p = getPart(ch)
                        if p and p.Parent and visible(p) then
                            local sp, on = cam:WorldToViewportPoint(aimPos(p))
                            if on then
                                local d = (Vector2.new(sp.X, sp.Y) - r).Magnitude
                                if d < bd then bd = d; bestPart = p end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

local fovC = Drawing.new("Circle")
fovC.NumSides = 64
fovC.Color = Color3.fromRGB(168,85,247)
fovC.Visible = false
RS.RenderStepped:Connect(function()
    fovC.Position = ref()
    fovC.Radius = c.FOVRadius
    fovC.Thickness = c.FovThickness
    fovC.Filled = c.FovFilled
    fovC.Visible = c.FovEnabled and c.Enabled
end)

if hookmetamethod and checkcaller then
    local oi
    oi = hookmetamethod(game, "__index", function(s, k)
        if not checkcaller() and c.Enabled and s == mouse then
            if k == "Hit" or k == "Target" or k == "UnitRay" then
                if math.random(1,100) > c.HitChance then
                    return oi(s, k)
                end
                local t = target()
                if not t then return oi(s, k) end
                local aim = aimPos(t)
                if k == "Hit" then
                    return aim
                elseif k == "Target" then
                    return t
                elseif k == "UnitRay" then
                    local ch = LP.Character
                    local head = ch and ch:FindFirstChild("Head")
                    local origin = head and head.Position or cam.CFrame.Position
                    local dir = aim - origin
                    if dir.Magnitude < 0.01 then return oi(s, k) end
                    return Ray.new(origin, dir.Unit)
                end
            end
        end
        return oi(s, k)
    end)
end

local wraps = RS2:FindFirstChild("Wraps")
local knives = RS2:FindFirstChild("Knives")

local function skinList(tool)
    local l = {"None"}
    local f = wraps and wraps:FindFirstChild("["..tool.."]")
    if f then for _, x in ipairs(f:GetChildren()) do table.insert(l, x.Name) end end
    return l
end
local function knifeList()
    local l = {"None"}
    if knives then for _, x in ipairs(knives:GetChildren()) do table.insert(l, x.Name) end end
    return l
end
local function applySkin(tool)
    if not c.SkinChanger.Enabled or not tool or not tool:IsA("Tool") then return end
    local name = tool.Name:match("^%[(.+)%]$")
    if not name then return end
    local skin = c.SkinChanger.Skins[name]
    if name == "Knife" then skin = c.SkinChanger.Knife end
    local old = tool:FindFirstChild("SkinModel")
    if old then old:Destroy() end
    if not skin or skin == "" or skin == "None" then
        local h = tool:FindFirstChild("Handle")
        if h and h:IsA("BasePart") then h.Transparency = 0 end
        return
    end
    local src
    if name == "Knife" then src = knives and knives:FindFirstChild(skin)
    else
        local root = wraps and wraps:FindFirstChild("["..name.."]")
        src = root and root:FindFirstChild(skin)
    end
    if not src then return end
    local h = tool:FindFirstChild("Handle")
    if not h or not h:IsA("BasePart") then return end
    local clone = src:Clone()
    clone.Name = "SkinModel"
    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("BasePart") then
            d.CanCollide = false; d.Anchored = false; d.Massless = true
        elseif d:IsA("MeshPart") then
            local sa = d:FindFirstChildOfClass("SurfaceAppearance")
            if sa then sa:Destroy() end
        end
    end
    local prim = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
    if not prim then clone:Destroy() return end
    clone.PrimaryPart = prim
    clone.Parent = tool
    clone:PivotTo(h.CFrame)
    for _, p in ipairs(clone:GetDescendants()) do
        if p:IsA("BasePart") then
            local w = Instance.new("WeldConstraint")
            w.Part0 = h; w.Part1 = p; w.Parent = p
        end
    end
    h.Transparency = 1
end
local function scanChar(ch)
    if not ch then return end
    for _, x in ipairs(ch:GetChildren()) do
        if x:IsA("Tool") then task.defer(function() applySkin(x) end) end
    end
    ch.ChildAdded:Connect(function(x)
        if x:IsA("Tool") then task.defer(function() applySkin(x) end) end
    end)
end
if LP.Character then task.spawn(scanChar, LP.Character) end
LP.CharacterAdded:Connect(function(ch) task.wait(1) scanChar(ch) end)

local BeamHash = {
    DoubleBarrel = "109d1326878cc594bc1bb42d126250810999782f",
    Revolver = "539db315b53f77390c0aa74773158e25bedcdd6e",
    Shotgun = "b415a7273aa86cbc2adc445fde5435eb5afababa",
    SMG = "005af87725b42ac4ca8103d11af6bf0c7d55f7b3",
    TacticalShotgun = "109d1326878cc594bc1bb42d126250810999782f",
}
local function applyBeams()
    if not c.BulletBeams.Enabled then return end
    local df = LP:FindFirstChild("DataFolder")
    if not df then return end
    local inv = df:FindFirstChild("InventoryData")
    if not inv then return end
    local eq = df:FindFirstChild("EquippedBulletBeams")
    local ib = inv:FindFirstChild("BulletBeams")
    if ib and ib:IsA("StringValue") then
        local d = {}
        if ib.Value ~= "" then pcall(function() d = HS:JSONDecode(ib.Value) end) end
        if type(d) ~= "table" then d = {} end
        for _, h in pairs(BeamHash) do d[h] = {Name = c.BulletBeams.Selected} end
        ib.Value = HS:JSONEncode(d)
    end
    if eq and eq:IsA("StringValue") then
        eq.Value = HS:JSONEncode({
            ["[DoubleBarrel]"] = BeamHash.DoubleBarrel,
            ["[Revolver]"] = BeamHash.Revolver,
            ["[TacticalShotgun]"] = BeamHash.TacticalShotgun,
            ["[SMG]"] = BeamHash.SMG,
            ["[Shotgun]"] = BeamHash.Shotgun,
        })
    end
end

local wsConn
local function applyWS()
    if wsConn then wsConn:Disconnect(); wsConn = nil end
    local ch = LP.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if c.WalkSpeed.Enabled then
        hum.WalkSpeed = c.WalkSpeed.Value
        wsConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if c.WalkSpeed.Enabled and hum.WalkSpeed ~= c.WalkSpeed.Value then
                hum.WalkSpeed = c.WalkSpeed.Value
            end
        end)
    else
        hum.WalkSpeed = c.WalkSpeed.Default
    end
end
LP.CharacterAdded:Connect(function() task.wait(1); applyWS() end)
if LP.Character then task.spawn(applyWS) end

-- TOOL GRABBER
local tgTools = {}
local tgActive = false
local tgStates = {}
local tgAcquired = {}
local tgConn = nil

local function tgOwns(name)
    local ok, res = pcall(function()
        local bp = LP:FindFirstChild("Backpack")
        local ch = LP.Character
        return (bp and bp:FindFirstChild(name) ~= nil) or (ch and ch:FindFirstChild(name) ~= nil)
    end)
    return ok and res or false
end
local function tgEmit(name, msg)
    if tgStates[name] == msg then return end
    tgStates[name] = msg
    print(("[TG][%s]: %s"):format(name, msg))
end
local function tgGrab(tool, src)
    if not tgActive then return end
    pcall(function()
        if not tool or not tool.Parent then return end
        if not tool:IsA("Tool") then return end
        if not tgTools[tool.Name] then return end
        if tgOwns(tool.Name) then return end
        if tgAcquired[tool.Name] then return end
        local bp = LP:FindFirstChild("Backpack")
        if not bp then return end
        tgAcquired[tool.Name] = true
        local copy = tool:Clone()
        task.wait(0.1)
        copy.Parent = bp
        print(("[TG][acquired] %s (src: %s)"):format(tool.Name, src or "?"))
    end)
end
local function tgSweep(container)
    if not container then return end
    pcall(function()
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("Tool") and tgTools[obj.Name] then
                if not tgOwns(obj.Name) and not tgAcquired[obj.Name] then
                    tgGrab(obj, "sweep")
                end
            end
        end
    end)
end
local function tgSweepPlayers()
    pcall(function()
        local bucket = workspace:FindFirstChild("Players")
        if bucket then tgSweep(bucket) end
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= LP then
                if pl.Character then tgSweep(pl.Character) end
                local bp = pl:FindFirstChild("Backpack")
                if bp then tgSweep(bp) end
            end
        end
    end)
end
local function tgPoll()
    tgSweep(workspace)
    task.wait(0.2)
    tgSweepPlayers()
end
local function tgLoop()
    while tgActive do
        local done = true
        for name in pairs(tgTools) do
            if not tgOwns(name) then
                done = false
                tgEmit(name, "searching...")
            else
                tgEmit(name, "acquired")
            end
        end
        if done then
            print("[TG][complete] all tools acquired")
            break
        end
        tgPoll()
        task.wait(1)
    end
end
local function tgRefreshTools()
    tgTools = {}
    if c.ToolGrabber.Flintlock then tgTools["[Flintlock]"] = true end
    if c.ToolGrabber.Balloon then tgTools["[Heart Balloon]"] = true end
end
local function tgStart()
    tgRefreshTools()
    if next(tgTools) == nil then
        tgActive = false
        return
    end
    tgStates = {}
    tgAcquired = {}
    tgActive = true
    if not tgConn then
        tgConn = workspace.DescendantAdded:Connect(function(obj)
            if not tgActive then return end
            task.wait(0.1)
            pcall(function()
                if obj:IsA("Tool") and tgTools[obj.Name] then
                    if not tgOwns(obj.Name) and not tgAcquired[obj.Name] then
                        tgGrab(obj, "descendant")
                    end
                end
            end)
        end)
    end
    task.spawn(tgLoop)
end
local function tgStop()
    tgActive = false
    if tgConn then tgConn:Disconnect(); tgConn = nil end
end

local T = {
    Bg = Color3.fromRGB(12,8,18),
    Pnl = Color3.fromRGB(20,14,28),
    PL = Color3.fromRGB(30,22,42),
    A = Color3.fromRGB(168,85,247),
    AG = Color3.fromRGB(200,130,255),
    Tx = Color3.fromRGB(230,220,245),
    Td = Color3.fromRGB(140,125,160),
    St = Color3.fromRGB(70,40,110),
    On = Color3.fromRGB(168,85,247),
    Off = Color3.fromRGB(45,32,60),
    Dg = Color3.fromRGB(220,60,120),
}

local function parentGui()
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end

local sg = Instance.new("ScreenGui")
sg.Name = "AngelsAndDimitrisHc"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 999
sg.Parent = parentGui()

-- MOBILE FAB
local fab = Instance.new("TextButton")
fab.Size = UDim2.new(0, 60, 0, 60)
fab.Position = UDim2.new(0, 20, 0.4, -30)
fab.BackgroundColor3 = T.Pnl
fab.Text = "AD"
fab.Font = Enum.Font.GothamBold
fab.TextSize = 20
fab.TextColor3 = T.A
fab.BorderSizePixel = 0
fab.AutoButtonColor = false
fab.Parent = sg
Instance.new("UICorner", fab).CornerRadius = UDim.new(1, 0)
local fabStroke = Instance.new("UIStroke", fab)
fabStroke.Color = T.A; fabStroke.Thickness = 2; fabStroke.Transparency = 0.4

local fabDrag, fabStart, fabPos
fab.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        fabDrag = true; fabStart = i.Position; fabPos = fab.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then fabDrag = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if fabDrag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = i.Position - fabStart
        fab.Position = UDim2.new(fabPos.X.Scale, fabPos.X.Offset + d.X, fabPos.Y.Scale, fabPos.Y.Offset + d.Y)
    end
end)

local main = Instance.new("Frame")
main.Size = UDim2.new(0.9, 0, 0.75, 0)
main.Position = UDim2.new(0.05, 0, 0.125, 0)
main.BackgroundColor3 = T.Bg
main.BorderSizePixel = 0
main.Active = true
main.Visible = false
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", main)
stroke.Color = T.A; stroke.Thickness = 1.5; stroke.Transparency = 0.3

fab.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    fab.Text = main.Visible and "X" or "AD"
end)

local hdr = Instance.new("Frame")
hdr.Size = UDim2.new(1, 0, 0, 56)
hdr.BackgroundColor3 = T.Pnl
hdr.BorderSizePixel = 0
hdr.Parent = main
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 14)
local hdrMask = Instance.new("Frame")
hdrMask.Size = UDim2.new(1, 0, 0, 20)
hdrMask.Position = UDim2.new(0, 0, 1, -20)
hdrMask.BackgroundColor3 = T.Pnl
hdrMask.BorderSizePixel = 0
hdrMask.Parent = hdr

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -140, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ANGELS AND DIMITRIS HC"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = T.Tx
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = hdr

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 100, 1, 0)
status.Position = UDim2.new(1, -110, 0, 0)
status.BackgroundTransparency = 1
status.Text = "OFF"
status.Font = Enum.Font.GothamMedium
status.TextSize = 12
status.TextColor3 = T.Dg
status.TextXAlignment = Enum.TextXAlignment.Right
status.Parent = hdr

local closeB = Instance.new("TextButton")
closeB.Size = UDim2.new(0, 44, 0, 44)
closeB.Position = UDim2.new(1, -52, 0.5, -22)
closeB.BackgroundColor3 = T.PL
closeB.Text = "X"
closeB.Font = Enum.Font.GothamBold
closeB.TextSize = 18
closeB.TextColor3 = T.Td
closeB.BorderSizePixel = 0
closeB.Parent = hdr
Instance.new("UICorner", closeB).CornerRadius = UDim.new(0, 8)

local dragging, dragStart, startPos
hdr.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = main.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = i.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

local body = Instance.new("ScrollingFrame")
body.Size = UDim2.new(1, -24, 1, -72)
body.Position = UDim2.new(0, 12, 0, 64)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ScrollBarThickness = 6
body.ScrollBarImageColor3 = T.A
body.CanvasSize = UDim2.new(0, 0, 0, 0)
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.Parent = main
local bl = Instance.new("UIListLayout", body)
bl.Padding = UDim.new(0, 10)
bl.SortOrder = Enum.SortOrder.LayoutOrder
local bp = Instance.new("UIPadding", body)
bp.PaddingTop = UDim.new(0, 6); bp.PaddingBottom = UDim.new(0, 12)

local function section(name)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, 0, 0, 0)
    s.AutomaticSize = E
