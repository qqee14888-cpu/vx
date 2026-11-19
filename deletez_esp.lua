-- esp by deletez (UI version + Names + Draggable + Toggles)
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
bg.Size = UDim2.new(0, 240, 0, 180)
bg.Position = UDim2.new(0, 20, 0, 20)
bg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
bg.BackgroundTransparency = 0.2
bg.BorderSizePixel = 0
bg.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = bg

-- Верхняя панель для перетаскивания
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundTransparency = 1
topBar.Parent = bg
topBar.Active = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 1, 0)
title.BackgroundTransparency = 1
title.Text = "ESP BY DELETEZ"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.Code
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0, 10, 0, 0)
title.Parent = topBar

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -10, 0, 20)
hint.BackgroundTransparency = 1
hint.Text = "[HOME] hide/show"
hint.TextColor3 = Color3.fromRGB(140, 140, 140)
hint.Font = Enum.Font.Code
hint.TextSize = 12
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Position = UDim2.new(0, 10, 0, 35)
hint.Parent = bg

-- Функция для создания переключателей (с ползунком)
local function createToggle(text, y, stateKey)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 25)
    row.Position = UDim2.new(0, 10, 0, y)
    row.BackgroundTransparency = 1
    row.Parent = bg

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 30, 0, 15)
    toggleBtn.Position = UDim2.new(1, -30, 0.5, -7.5)
    toggleBtn.BackgroundColor3 = State[stateKey] and Color3.fromRGB(180, 0, 255) or Color3.fromRGB(60, 60, 60)
    toggleBtn.Text = ""
    toggleBtn.BorderSizePixel = 0
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = row

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 11, 0, 11)
    knob.Position = State[stateKey] and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBtn
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    toggleBtn.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        toggleBtn.BackgroundColor3 = State[stateKey] and Color3.fromRGB(180, 0, 255) or Color3.fromRGB(60, 60, 60)
        if State[stateKey] then
            knob:TweenPosition(UDim2.new(1, -13, 0.5, -5.5), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        else
            knob:TweenPosition(UDim2.new(0, 2, 0.5, -5.5), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        end
    end)
end

createToggle("Box", 65, "Box")
createToggle("Skeleton", 95, "Skel")
createToggle("Chams", 125, "Chams")

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

-- Логика перетаскивания HUD
local dragging = false
local dragInput, dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = bg.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        bg.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Плавное скрытие меню по кнопке Home
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Home then
        State.HudOpen = not State.HudOpen
        if State.HudOpen then
            bg.Visible = true
            bg:TweenSize(UDim2.new(0, 240, 0, 180), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        else
            bg:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
            task.delay(0.2, function() if not State.HudOpen then bg.Visible = false end end)
        end
    end
end)

-- Создание BillboardGui для имени
local function createESP(player)
    if player == LocalPlayer or cache[player] then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "deletez_billboard"
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0) -- Поднимаем над головой повыше
    billboard.AlwaysOnTop = true
    billboard.Enabled = true
    
    -- Текст с ником (висит отдельно и всегда)
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
    
    local skelLines = {}
    for i = 1, 20 do
        local line = Instance.new("Frame")
        line.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
        line.BorderSizePixel = 0
        line.Visible = false
        line.Parent = gui
        table.insert(skelLines, line)
    end
    
    cache[player] = { bb = billboard, skel = skelLines }
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
    
    -- Управление боксом (рамкой вокруг ника)
    -- Бокс теперь сделан как Border у фрейма, который мы включаем/выключаем
    -- Чтобы он выглядел как бокс, мы делаем рамку вокруг всего BillBoard
    if State.Box then
        d.bb.Size = UDim2.new(0, 100, 0, 50) 
        -- Используем Outline для имитации бокса
    else
        d.bb.Size = UDim2.new(0, 100, 0, 15) -- Оставляем только под ник
    end
    
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
