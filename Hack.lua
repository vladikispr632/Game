-- ═══════════════════════════════════════════════════════════
-- UNIVERSAL GAME HUB — Part 1/3
-- Поддержка 20+ Roblox игр
-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════
-- СПИСОК ИГР
-- ═══════════════════════════════════════════════════════════
local GAMES = {
    { id = 4924922222, name = "Brookhaven RP" },
    { id = 17944790887, name = "Steal a Brainrot" },
    { id = 13622843653, name = "Steal a Egg" },
    { id = 8446954543, name = "Bloxburg" },
    { id = 920587237, name = "Adopt Me" },
    { id = 1962086868, name = "Tower of Hell" },
    { id = 286090429, name = "Arsenal" },
    { id = 142823291, name = "Murder Mystery 2" },
    { id = 606849621, name = "Jailbreak" },
    { id = 4368699004, name = "MeepCity" },
    { id = 2735585713, name = "Royal High" },
    { id = 4623386862, name = "Piggy" },
    { id = 6516141723, name = "Doors" },
    { id = 6233623986, name = "Rainbow Friends" },
    { id = 6872265039, name = "BedWars" },
    { id = 1773037943, name = "Build A Boat" },
    { id = 192000, name = "Theme Park Tycoon 2" },
    { id = 192000, name = "Restaurant Tycoon 2" },
    { id = 1537690962, name = "Bee Swarm Simulator" },
    { id = 292439477, name = "Pet Simulator" },
    { id = 10786152399, name = "Fisch" },
    { id = 189707, name = "Natural Disaster" },
    { id = 361404180, name = "Escape Room" },
    { id = 4983979333, name = "Da Hood" },
    { id = 155615604, name = "Prison Life" },
}

-- ═══════════════════════════════════════════════════════════
-- ХЕЛПЕРЫ
-- ═══════════════════════════════════════════════════════════
local function char()
    return LP.Character
end

local function hum()
    local c = char()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function root()
    local c = char()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function notify(t, txt, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = t, Text = txt, Duration = dur or 2
        })
    end)
end

local function getCurrentGame()
    for _, g in ipairs(GAMES) do
        if g.id == game.PlaceId then return g end
    end
    return { id = game.PlaceId, name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown" }
end-- ═══════════════════════════════════════════════════════════
-- UNIVERSAL GAME HUB — Part 2/3
-- Функции (работают в любой игре)
-- ═══════════════════════════════════════════════════════════

-- ═════ 1. ПРОЗРАЧНАЯ ПЛАТФОРМА (поднимает игрока) ═════
local platform = nil
local platformActive = false

local function togglePlatform()
    if platformActive then
        if platform then platform:Destroy() platform = nil end
        platformActive = false
        return
    end

    local r = root()
    if not r then return end

    -- Создаём прозрачную платформу под игроком
    platform = Instance.new("Part")
    platform.Name = "UserPlatform"
    platform.Size = Vector3.new(6, 0.5, 6)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.7
    platform.Color = Color3.fromRGB(0, 200, 255)
    platform.Material = Enum.Material.Neon
    platform.Position = r.Position - Vector3.new(0, 3, 0)
    platform.Parent = workspace

    platformActive = true
    notify("🚀 Платформа", "Платформа активирована")

    -- Постоянно держим платформу под игроком и поднимаем вверх
    task.spawn(function()
        local riseSpeed = 3
        while platformActive and platform and platform.Parent do
            local hrp = root()
            if hrp then
                platform.Position = Vector3.new(
                    hrp.Position.X,
                    platform.Position.Y + riseSpeed * 0.05,
                    hrp.Position.Z
                )
            end
            task.wait(0.05)
        end
    end)
end

-- ═════ 2. ESP ИГРОКОВ ═════
local espActive = false
local highlights = {}

local function toggleESP()
    espActive = not espActive
    for _, h in pairs(highlights) do
        if h and h.Parent then h:Destroy() end
    end
    highlights = {}
    if not espActive then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.FillTransparency = 0.5
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = p.Character
            highlights[p] = h
        end
    end
end

-- ═════ 3. FULLBRIGHT ═════
local fullbrightActive = false
local function toggleFullbright()
    fullbrightActive = not fullbrightActive
    if fullbrightActive then
        pcall(function()
            Lighting.Brightness = 3
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        end)
    else
        pcall(function()
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end)
    end
end

-- ═════ 4. FLY (безопасный, через BodyVelocity) ═════
local flyActive = false
local flyBV = nil
local function toggleFly()
    flyActive = not flyActive
    local r = root()
    if not r then return end
    if flyActive then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.Parent = r
        task.spawn(function()
            while flyActive and flyBV do
                local cam = workspace.CurrentCamera
                local move = Vector3.new(0, 0, 0)
                local speed = 50
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                    move = move + cam.CFrame.LookVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                    move = move - cam.CFrame.LookVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                    move = move - cam.CFrame.RightVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                    move = move + cam.CFrame.RightVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                    move = move + Vector3.new(0, 1, 0)
                end
                if move.Magnitude > 0 then
                    flyBV.Velocity = move.Unit * speed
                else
                    flyBV.Velocity = Vector3.new(0, 0, 0)
                end
                task.wait(0.05)
            end
        end)
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
    end
end

-- ═════ 5. NOCLIP ═════
local noclipActive = false
task.spawn(function()
    while true do
        if noclipActive then
            local c = char()
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        p.CanCollide = false
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- ═════ 6. SPEED ═════
local speedActive = false
task.spawn(function()
    while true do
        if speedActive then
            local h = hum()
            if h then h.WalkSpeed = 50 end
        end
        task.wait(0.5)
    end
end)

-- ═════ 7. JUMP ═════
local jumpActive = false
task.spawn(function()
    while true do
        if jumpActive then
            local h = hum()
            if h then h.UseJumpPower = true; h.JumpPower = 100 end
        end
        task.wait(0.5)
    end
end)

-- ═════ 8. INFINITE JUMP ═════
local infJumpActive = false
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpActive then
        local h = hum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ═════ 9. TELEPORT TO PLAYER ═════
local function teleportToPlayer(name)
    local r = root()
    if not r then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(name:lower()) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            r.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            return
        end
    end
end

-- ═════ 10. AUTO FARM (универсальный) ═════
local autoFarmActive = false
task.spawn(function()
    while true do
        if autoFarmActive then
            local r = root()
            if r then
                -- Ищем любые "collectible" объекты и идём к ним
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if (obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("cash"))
                       and (obj:IsA("BasePart")) then
                        local h = hum()
                        if h then h:MoveTo(obj.Position) end
                        break
                    end
                end
            end
        end
        task.wait(1)
    end
end)

-- ═════ 11. SERVER HOP ═════
local function serverHop()
    local TS = game:GetService("TeleportService")
    local Http = game:GetService("HttpService")
    local ok, servers = pcall(function()
        return Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and servers and servers.data then
        for _, s in ipairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TS:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                return
            end
        end
    end
end

-- ═════ 12. RESPAWN ═════
local function respawn()
    local h = hum()
    if h then h.Health = 0 end
end-- ═══════════════════════════════════════════════════════════
-- UNIVERSAL GAME HUB — Part 3/3
-- GUI со всеми функциями
-- ═══════════════════════════════════════════════════════════

local old = PG:FindFirstChild("UniversalHub")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "UniversalHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PG

-- ═════ ОСНОВНАЯ ПАНЕЛЬ ═════
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 340, 0, 560)
panel.Position = UDim2.new(0.5, -170, 0.5, -280)
panel.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

local pStroke = Instance.new("UIStroke", panel)
pStroke.Color = Color3.fromRGB(0, 200, 255)
pStroke.Thickness = 2

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 55)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
titleBar.BorderSizePixel = 0
titleBar.Parent = panel
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 20)
titleFix.Position = UDim2.new(0, 0, 1, -20)
titleFix.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎮 UNIVERSAL HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Текущая игра
local gameLbl = Instance.new("TextLabel")
gameLbl.Size = UDim2.new(1, -60, 0, 20)
gameLbl.Position = UDim2.new(0, 15, 1, -22)
gameLbl.BackgroundTransparency = 1
gameLbl.Text = "Игра: " .. getCurrentGame().name
gameLbl.TextColor3 = Color3.fromRGB(220, 240, 255)
gameLbl.TextSize = 11
gameLbl.Font = Enum.Font.Gotham
gameLbl.TextXAlignment = Enum.TextXAlignment.Left
gameLbl.Parent = titleBar

local closeX = Instance.new("TextButton")
closeX.Size = UDim2.new(0, 30, 0, 30)
closeX.Position = UDim2.new(1, -38, 0, 12)
closeX.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeX.Text = "✖"
closeX.TextColor3 = Color3.fromRGB(255, 255, 255)
closeX.TextSize = 14
closeX.Font = Enum.Font.GothamBold
closeX.BorderSizePixel = 0
closeX.Parent = titleBar
Instance.new("UICorner", closeX).CornerRadius = UDim.new(0, 8)
closeX.MouseButton1Click:Connect(function() panel.Visible = false end)

-- Табы (вкладки)
local tabsBar = Instance.new("Frame")
tabsBar.Size = UDim2.new(1, -10, 0, 36)
tabsBar.Position = UDim2.new(0, 5, 0, 60)
tabsBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
tabsBar.BorderSizePixel = 0
tabsBar.Parent = panel
Instance.new("UICorner", tabsBar).CornerRadius = UDim.new(0, 8)

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.Padding = UDim.new(0, 3)
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Parent = tabsBar

local currentTab = "universal"
local tabBtns = {}

local function switchTab(tabId)
    currentTab = tabId
    for id, btn in pairs(tabBtns) do
        if id == tabId then
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        end
    end
    -- Перерисовка контента
    renderContent()
end

-- Скролл для контента
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -145)
scroll.Position = UDim2.new(0, 5, 0, 100)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
scroll.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local function clearContent()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local function makeBtn(text, col, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 38)
    b.BackgroundColor3 = col
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function() cb(b) end)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, col.R * 255 + 30),
                math.min(255, col.G * 255 + 30),
                math.min(255, col.B * 255 + 30)
            )
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = col }):Play()
    end)
    return b
end

local function makeInfo(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 0, 24)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(200, 220, 240)
    l.TextSize = 11
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = scroll
    return l
end

-- Функция отрисовки контента по табу
function renderContent()
    clearContent()

    if currentTab == "universal" then
        makeInfo("🌐 УНИВЕРСАЛЬНЫЕ ФУНКЦИИ (работают везде)")

        makeBtn("🚀 1. ПРОЗРАЧНАЯ ПЛАТФОРМА: ВЫКЛ", Color3.fromRGB(0, 170, 200), function(b)
            togglePlatform()
            b.Text = platformActive and "🚀 1. ПРОЗРАЧНАЯ ПЛАТФОРМА: ВКЛ" or "🚀 1. ПРОЗРАЧНАЯ ПЛАТФОРМА: ВЫКЛ"
            b.BackgroundColor3 = platformActive and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(0, 170, 200)
        end)

        makeBtn("👁️ 2. ESP ИГРОКОВ: ВЫКЛ", Color3.fromRGB(150, 50, 50), function(b)
            toggleESP()
            b.Text = espActive and "👁️ 2. ESP ИГРОКОВ: ВКЛ" or "👁️ 2. ESP ИГРОКОВ: ВЫКЛ"
            b.BackgroundColor3 = espActive and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(150, 50, 50)
        end)

        makeBtn("💡 3. FULLBRIGHT: ВЫКЛ", Color3.fromRGB(200, 150, 0), function(b)
            toggleFullbright()
            b.Text = fullbrightActive and "💡 3. FULLBRIGHT: ВКЛ" or "💡 3. FULLBRIGHT: ВЫКЛ"
            b.BackgroundColor3 = fullbrightActive and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(200, 150, 0)
        end)

        makeBtn("✈️ 4. FLY: ВЫКЛ", Color3.fromRGB(80, 80, 180), function(b)
            toggleFly()
            b.Text = flyActive and "✈️ 4. FLY: ВКЛ" or "✈️ 4. FLY: ВЫКЛ"
            b.BackgroundColor3 = flyActive and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(80, 80, 180)
        end)

        makeBtn("👻 5. NOCLIP: ВЫКЛ", Color3.fromRGB(100, 50, 150), function(b)
            noclipActive = not noclipActive
            b.Text = noclipActive and "👻 5. NOCLIP: ВКЛ" or "👻 5. NOCLIP: ВЫКЛ"
            b.BackgroundColor3 = noclipActive and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(100, 50, 150)
        end)

        makeBtn("⚡ 6. SPEED 50: ВЫКЛ", Color3.fromRGB(0, 170, 80), function(b)
            speedActive = not speedActive
            b.Text = speedActive and "⚡ 6. SPEED 50: ВКЛ" or "⚡ 6. SPEED 50: ВЫКЛ"
            b.BackgroundColor3 = speedActive and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(0, 170, 80)
            if not speedActive then
                local h = hum()
                if h then h.WalkSpeed = 16 end
            end
        end)

        makeBtn("🦘 7. ВЫСОКИЙ ПРЫЖОК: ВЫКЛ", Color3.fromRGB(0, 170, 80), function(b)
            jumpActive = not jumpActive
            b.Text = jumpActive and "🦘 7. ВЫСОКИЙ ПРЫЖОК: ВКЛ" or "🦘 7. ВЫСОКИЙ ПРЫЖОК: ВЫКЛ"
            b.BackgroundColor3 = jumpActive and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(0, 170, 80)
            if not jumpActive then
                local h = hum()
                if h then h.JumpPower = 50 end
            end
        end)

        makeBtn("🦘 8. INFINITE JUMP: ВЫКЛ", Color3.fromRGB(80, 80, 180), function(b)
            infJumpActive = not infJumpActive
            b.Text = infJumpActive and "🦘 8. INFINITE JUMP: ВКЛ" or "🦘 8. INFINITE JUMP: ВЫКЛ"
            b.BackgroundColor3 = infJumpActive and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(80, 80, 180)
        end)

        makeBtn("🔄 9. RESPAWN", Color3.fromRGB(150, 50, 50), function()
            respawn()
        end)

        makeBtn("🌐 10. SERVER HOP", Color3.fromRGB(0, 100, 200), function()
            serverHop()
        end)

        makeBtn("📊 11. МОЯ ПОЗИЦИЯ", Color3.fromRGB(80, 80, 140), function()
            local r = root()
            if r then
                notify("Позиция", string.format("%.0f, %.0f, %.0f", r.Position.X, r.Position.Y, r.Position.Z))
            end
        end)

        makeBtn("ℹ️ 12. ИНФО О ИГРЕ", Color3.fromRGB(80, 80, 140), function()
            local g = getCurrentGame()
            notify("Игра", g.name)
        end)

    elseif currentTab == "teleport" then
        makeInfo("📍 ТЕЛЕПОРТ К ИГРОКУ")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                makeBtn("→ " .. p.Name, Color3.fromRGB(80, 80, 140), function()
                    teleportToPlayer(p.Name)
                end)
            end
        end

    elseif currentTab == "farm" then
        makeInfo("💰 АВТО-ФАРМ (универсальный)")

        makeBtn("💰 АВТО-ФАРМ: ВЫКЛ", Color3.fromRGB(150, 100, 0), function(b)
            autoFarmActive = not autoFarmActive
            b.Text = autoFarmActive and "💰 АВТО-ФАРМ: ВКЛ" or "💰 АВТО-ФАРМ: ВЫКЛ"
            b.BackgroundColor3 = autoFarmActive and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(150, 100, 0)
        end)

        makeInfo("⏱️ Авто-фарм ищет монеты/гемы/кэш и идёт к ним")

    elseif currentTab == "games" then
        makeInfo("🎮 СПИСОК ИГР (" .. #GAMES .. ")")
        for _, g in ipairs(GAMES) do
            local isCurrent = (g.id == game.PlaceId)
            makeBtn((isCurrent and "🟢 " or "🔹 ") .. g.name, 
                isCurrent and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(50, 50, 80),
                function()
                    if not isCurrent then
                        pcall(function()
                            game:GetService("TeleportService"):Teleport(g.id, LP)
                        end)
                    end
                end)
        end
    end
end

-- Создаём табы
local tabList = {
    { id = "universal", name = "🌐 Универсал" },
    { id = "teleport", name = "📍 ТП" },
    { id = "farm", name = "💰 Фарм" },
    { id = "games", name = "🎮 Игры" },
}

for _, t in ipairs(tabList) do
    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(0, 78, 1, 0)
    tb.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    tb.Text = t.name
    tb.TextColor3 = Color3.fromRGB(255, 255, 255)
    tb.TextSize = 11
    tb.Font = Enum.Font.GothamBold
    tb.BorderSizePixel = 0
    tb.Parent = tabsBar
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
    tb.MouseButton1Click:Connect(function() switchTab(t.id) end)
    tabBtns[t.id] = tb
end

switchTab("universal")

notify("🎮 Universal Hub", "20+ игр. Загружено.")
print("[UniversalHub] Загружено. Игра: " .. getCurrentGame().name)
