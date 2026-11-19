-- esp by deletez (UI version + Names)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local State = { Box = true, Skel = true, Chams = true, HudOpen = true }
local cache = {}
local chams = {}

-- Создаем HUD (меню)
local gui = Instance.new("ScreenGui")
gui.Name = "DeletezESP"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = game:GetService("CoreGui")

local bg = Instance.new("Frame")
bg.Size = UDim2.new(0, 220, 0, 160)
bg.Position = UDim2.new(0, 20, 0, 20)
bg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
bg.BackgroundTransparency = 0.2
bg.BorderSizePixel = 0
bg.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = bg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ESP BY DELETEZ"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.Code
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0, 10, 0, 5)
title.Parent = bg

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, 0, 0, 20)
hint.BackgroundTransparency = 1
hint.Text = "[HOME] hide/show"
hint.TextColor3 = Color3.fromRGB(140, 140, 140)
hint.Font = Enum.Font.Code
hint.TextSize = 12
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Position = UDim2.new(0, 10, 0, 30)
hint.Parent = bg

-- Функция для создания кликабельных строк в меню
local function createButton(text, y, stateKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(180, 0, 255)
    btn.Font = Enum.Font.Code
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = bg
    
    btn.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        btn.TextColor3 = State[stateKey] and Color3.fromRGB(180, 0, 255) or Color3.fromRGB(100, 100, 100)
    end)
end

createButton("[+] Box", 60, "Box")
createButton("[+] Skeleton", 85, "Skel")
createButton("[+] Chams", 110, "Chams")

local foot = Instance.new("TextLabel")
foot.Size = UDim2.new(1, 0, 0, 20)
foot.BackgroundTransparency = 1
foot.Text = "esp by deletez"
foot.TextColor3 = Color3.fromRGB(100, 100, 100)
foot.Font = Enum.Font.Code
foot.TextSize = 11
foot.TextXAlignment = Enum.TextXAlignment.Left
foot.Position = UDim2.new(0, 10, 1, -25)
foot.Parent = bg

-- Плавное скрытие меню по кнопке Home
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Home then
        State.HudOpen = not State.HudOpen
        if State.HudOpen then
            bg.Visible = true
            bg:TweenSize(UDim2.new(0, 220, 0, 160), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            bg:TweenPosition(UDim2.new(0, 20, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        else
            bg:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            bg:TweenPosition(UDim2.new(0, 20, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            task.delay(0.2, function() if not State.HudOpen then bg.Visible = false end end)
        end
    end
end)

-- Создание BillboardGui для имени и бокса
local function createESP(player)
    if player == LocalPlayer or cache[player] then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "deletez_billboard"
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0) -- Поднимаем над головой
    billboard.AlwaysOnTop = true
    billboard.Enabled = true
    
    -- Текст с ником (будет виден всегда)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 15)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.Code
    nameLabel.TextSize = 12
    nameLabel.Parent = billboard
    
    -- Рамка (бокс) вокруг игрока
    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(1, 0, 1, -15)
    boxFrame.Position = UDim2.new(0, 0, 0, 15)
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderSizePixel = 2
    boxFrame.BorderColor3 = Color3.fromRGB(180, 0, 255)
    boxFrame.Parent = billboard
    
    local skelLines = {}
    for i = 1, 20 do
        local line = Instance.new("Frame")
        line.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
        line.BorderSizePixel = 0
        line.Visible = false
        line.Parent = gui
        table.insert(skelLines, line)
    end
    
    cache[player] = { bb = billboard, box = boxFrame, skel = skelLines }
end

local function removeESP(player)
    local d = cache[player]
    if not d then return end
    if d.bb then d.bb:Destroy() end
    for _, l in ipairs(d.skel) do l:Destroy() end
    cache[player] = nil
end

-- Скелет
local R6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
local R15 = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"RightUpperArm","RightLowerArm"},{"LeftLowerArm","LeftHand"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LowerTorso","RightUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"RightUpperLeg","RightLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"RightLowerLeg","RightFoot"}}

local function part(c, n)
    local p = c:FindFirstChild(n)
    return p and p:IsA("BasePart") and p.Position or nil
end

local function w2s(v)
    local s, on = Camera:WorldToViewportPoint(v)
    return on and Vector2.new(s.X, s.Y) or nil
end

-- Chams
local function clearChams()
    for _, h in pairs(chams) do if h.Parent then h:Destroy() end end
    chams = {}
end

local function setChams(c)
    if chams[c] and chams[c].Parent then return end
    local h = Instance.new("Highlight")
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillColor = Color3.fromRGB(180, 0, 255)
    h.FillTransparency = 0.55
    h.OutlineColor = Color3.fromRGB(180, 0, 255)
    h.OutlineTransparency = 0
    h.Parent = c
    chams[c] = h
end

-- Отрисовка
local function drawESP(p, d)
    local c = p.Character
    local hu = c and c:FindFirstChildOfClass("Humanoid")
    if not c or not hu or hu.Health <= 0 then
        if d.bb then d.bb.Enabled = false end
        for _, l in ipairs(d.skel) do l.Visible = false end
        return
    end
    
    local hd = part(c, "Head")
    local hr = c:FindFirstChild("HumanoidRootPart")
    if not hd or not hr then return end
    
    -- Прикрепляем Billboard к голове
    if d.bb.Parent ~= hd then d.bb.Parent = hd end
    d.bb.Enabled = true
    
    -- Включаем/выключаем рамку (бокс)
    d.box.Visible = State.Box
    
    -- Скелет
    local ls = (hu.RigType == Enum.HumanoidRigType.R15) and R15 or R6
    local ix = 1
    for _, pr in ipairs(ls) do
        local a, b = part(c, pr[1]), part(c, pr[2])
        if a and b and d.skel[ix] then
            local sa, sb = w2s(a), w2s(b)
            local l = d.skel[ix]
            if State.Skel and sa and sb then
                local mag = (sa - sb).Magnitude
                local angle = math.deg(math.atan2(sb.Y - sa.Y, sb.X - sa.X))
                l.Size = UDim2.new(0, mag, 0, 1)
                l.Position = UDim2.new(0, sa.X, 0, sa.Y)
                l.Rotation = angle
                l.Visible = true
            else
                l.Visible = false
            end
            ix = ix + 1
        end
    end
    for i = ix, #d.skel do d.skel[i].Visible = false end
end

local function updChams()
    if not State.Chams then clearChams() return end
    local sn, n = {}, 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and n < 28 then
            local hr = p.Character:FindFirstChild("HumanoidRootPart")
            if hr then
                local _, on = Camera:WorldToViewportPoint(hr.Position)
                local ds = (Camera.CFrame.Position - hr.Position).Magnitude
                if on or ds < 100 then setChams(p.Character) sn[p.Character] = true n = n + 1 end
            end
        end
    end
    for c, h in pairs(chams) do
        if not sn[c] or not h.Parent then
            if h.Parent then h:Destroy() end
            chams[c] = nil
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

local ac = 0
RunService.RenderStepped:Connect(function(dt)
    ac = ac + dt
    if ac >= 1 / 30 then
        ac = 0
        for p, d in pairs(cache) do
            if p.Parent and p.Character then drawESP(p, d) else removeESP(p) end
        end
        updChams()
    end
end)
