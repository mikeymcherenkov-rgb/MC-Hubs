--[[
    PRO CHEAT HUB v3.1 FIXED
    Исправленный полёт + блок под собой
]]

-- // Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local PhysicsService = game:GetService("PhysicsService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // Anti-Cheat Bypass
local function setupBypass()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if method == "FireServer" then
            local name = tostring(self)
            if name:find("Kick") or name:find("Ban") then
                return nil
            end
        end
        
        if method == "Kick" or method == "kick" then
            return nil
        end
        
        return oldNamecall(self, ...)
    end)
    
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if tostring(self) == "Humanoid" then
            if key == "WalkSpeed" or key == "JumpPower" or key == "MaxHealth" or key == "Health" then
                return oldIndex(self, key)
            end
        end
        if key == "Detected" or key == "Checking" or key == "Verify" then
            return false
        end
        return oldIndex(self, key)
    end)
end
pcall(setupBypass)

-- // Settings
local Settings = {
    -- Movement
    Flight = {Enabled = false, Speed = 50},
    Speed = {Enabled = false, Value = 32},
    Jump = {Enabled = false, Value = 100},
    InfiniteJump = {Enabled = false},
    NoClip = {Enabled = false},
    ClickTP = {Enabled = false},
    BHop = {Enabled = false},
    AutoRun = {Enabled = false},
    SpinBot = {Enabled = false, Speed = 10},
    Jesus = {Enabled = false},
    Glide = {Enabled = false},
    LowGravity = {Enabled = false},
    WallWalk = {Enabled = false},
    
    -- Block Spawn
    BlockSpawn = {Enabled = false, Size = 10, Material = "SmoothPlastic", Color = Color3.fromRGB(255, 255, 255)},
    
    -- Visual
    ESP = {Enabled = false, Boxes = true, Tracers = true, Names = true, Distance = true, Health = true},
    FullBright = {Enabled = false},
    FOV = 70,
    NoFog = {Enabled = false},
    Chams = {Enabled = false},
    XRay = {Enabled = false},
    Wireframe = {Enabled = false},
    ThirdPerson = {Enabled = false},
    NoZoom = {Enabled = false},
    
    -- Combat
    Aimbot = {Enabled = false, FOV = 100, Smoothness = 0.5, TargetPart = "Head", TeamCheck = false, VisibilityCheck = true},
    TriggerBot = {Enabled = false, Delay = 0.1},
    SilentAim = {Enabled = false, FOV = 50},
    AutoShoot = {Enabled = false},
    KillAura = {Enabled = false, Range = 20},
    Reach = {Enabled = false, Value = 15},
    NoRecoil = {Enabled = false},
    NoSpread = {Enabled = false},
    InstantReload = {Enabled = false},
    InfiniteAmmo = {Enabled = false},
    RapidFire = {Enabled = false},
    BulletTP = {Enabled = false},
    
    -- World
    AntiAfk = {Enabled = false},
    TimeChanger = {Enabled = false, Time = 14},
    Weather = {Enabled = false, Type = "Clear"},
    Gravity = {Enabled = false, Value = 196.2},
    WalkSpeedGlobal = 16,
    NukeAll = {Enabled = false},
    
    -- Character
    GodMode = {Enabled = false},
    Invisible = {Enabled = false},
    Freeze = {Enabled = false},
    Respawn = {Enabled = false},
    TeleportTools = {Enabled = false},
    CloneCharacter = {Enabled = false},
    GiantMode = {Enabled = false},
    TinyMode = {Enabled = false},
    
    -- Fun
    RainbowChar = {Enabled = false},
    Spin = {Enabled = false},
    Headless = {Enabled = false},
    Sit = {Enabled = false},
    Lay = {Enabled = false},
    
    -- Misc
    StreamSnipe = {Enabled = false},
    AutoReconnect = {Enabled = false},
    ChatSpy = {Enabled = false},
    SilentChat = {Enabled = false},
    
    -- Settings
    ConfigName = "Default",
    AutoExecute = {Enabled = false},
    CustomCursor = {Enabled = false},
    Watermark = {Enabled = true}
}

local FlightObjects = {}
local ESPObjects = {}
local AimbotConnection = nil
local TriggerBotConnection = nil
local Connections = {}
local SpawnedBlocks = {}

-- // Utility Functions
local function getChar()
    return LocalPlayer.Character
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getClosestPlayer(range)
    local closest = nil
    local shortestDistance = range or math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local myRoot = getRoot()
                if root and myRoot then
                    local distance = (root.Position - myRoot.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

local function getClosestPlayerToCursor()
    local closest = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

local function raycast(from, to, ignore)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignore and {ignore} or {getChar()}
    return Workspace:Raycast(from, (to - from).Unit * (to - from).Magnitude, params)
end

local function isVisible(target)
    local myRoot = getRoot()
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return false end
    
    local ray = raycast(myRoot.Position, targetRoot.Position, getChar())
    if ray then
        local hit = ray.Instance
        if hit:IsDescendantOf(target.Character) then
            return true
        end
    end
    return false
end

local function notify(title, text, dur)
    spawn(function()
        local sg = Instance.new("ScreenGui")
        sg.Parent = game:GetService("CoreGui")
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 300, 0, 70)
        f.Position = UDim2.new(1, 0, 0.7, 0)
        f.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
        f.BorderSizePixel = 0
        f.Parent = sg
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = f
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 170, 255)
        stroke.Thickness = 1
        stroke.Parent = f
        
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, 0, 0, 25)
        tl.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        tl.Text = title
        tl.TextColor3 = Color3.new(1, 1, 1)
        tl.Font = Enum.Font.SourceSansBold
        tl.TextSize = 13
        tl.Parent = f
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 0, 45)
        txt.Position = UDim2.new(0, 8, 0, 25)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        txt.Font = Enum.Font.SourceSans
        txt.TextSize = 12
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Parent = f
        
        f:TweenPosition(UDim2.new(1, -312, 0.7, 0), "Out", "Quart", 0.3)
        task.wait(dur or 2.5)
        f:TweenPosition(UDim2.new(1, 0, 0.7, 0), "In", "Quart", 0.3)
        task.wait(0.3)
        sg:Destroy()
    end)
end

-- ============ ИСПРАВЛЕННЫЙ ПОЛЁТ ============
local function setupFlight()
    local char = getChar()
    if not char then return end
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end
    
    -- Очистка старых объектов
    if FlightObjects.Connection then
        FlightObjects.Connection:Disconnect()
        FlightObjects.Connection = nil
    end
    if FlightObjects.Gyro then 
        FlightObjects.Gyro:Destroy() 
        FlightObjects.Gyro = nil
    end
    if FlightObjects.Velocity then 
        FlightObjects.Velocity:Destroy() 
        FlightObjects.Velocity = nil
    end
    
    if not Settings.Flight.Enabled then
        hum.PlatformStand = false
        return
    end
    
    hum.PlatformStand = true
    
    -- BodyGyro для удержания направления
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 10000
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root
    FlightObjects.Gyro = bodyGyro
    
    -- BodyVelocity для движения
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root
    FlightObjects.Velocity = bodyVelocity
    
    -- Основной цикл полёта
    FlightObjects.Connection = RunService.Heartbeat:Connect(function()
        if not Settings.Flight.Enabled then return end
        if not root or not hum or hum.Health <= 0 then 
            setupFlight() -- перезапуск при смерти
            return 
        end
        
        -- ПОЛНОСТЬЮ ПЕРЕПИСАННАЯ ЛОГИКА УПРАВЛЕНИЯ
        local moveVector = Vector3.zero
        local cameraForward = Camera.CFrame.LookVector
        local cameraRight = Camera.CFrame.RightVector
        
        -- WASD - правильные направления относительно камеры
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector += cameraForward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector -= cameraForward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector -= cameraRight
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector += cameraRight
        end
        
        -- Вертикальное движение (ВВЕРХ = Space, ВНИЗ = LeftShift)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector += Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector -= Vector3.new(0, 1, 0)
        end
        
        -- Турбо-режим на LeftControl
        local speedMultiplier = 1
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            speedMultiplier = 2.5
        end
        
        -- Применяем движение
        if moveVector.Magnitude > 0 then
            bodyVelocity.Velocity = moveVector.Unit * Settings.Flight.Speed * speedMultiplier
        else
            bodyVelocity.Velocity = Vector3.zero
        end
        
        -- Направление всегда по камере
        bodyGyro.CFrame = CFrame.new(root.Position, root.Position + Camera.CFrame.LookVector)
    end)
end

-- ============ СОЗДАНИЕ БЛОКА ПОД СОБОЙ ============
local function spawnBlockUnder()
    local root = getRoot()
    if not root then return end
    
    -- Позиция под персонажем
    local spawnPos = root.Position - Vector3.new(0, 5, 0)
    
    -- Проверяем, нет ли уже блоков (опционально)
    if #SpawnedBlocks > 50 then
        -- Удаляем старые блоки если их больше 50
        for i = 1, 10 do
            local oldBlock = table.remove(SpawnedBlocks, 1)
            if oldBlock then
                oldBlock:Destroy()
            end
        end
    end
    
    -- Создаём блок
    local block = Instance.new("Part")
    block.Name = "SpawnedBlock_" .. os.time()
    block.Size = Vector3.new(Settings.BlockSpawn.Size, 2, Settings.BlockSpawn.Size)
    block.Position = spawnPos
    block.Anchored = true
    block.CanCollide = true
    block.Material = Enum.Material[Settings.BlockSpawn.Material]
    block.Color = Settings.BlockSpawn.Color
    block.Parent = Workspace
    
    -- Добавляем в список
    table.insert(SpawnedBlocks, block)
    
    -- Уведомление
    notify("Block Spawned", "Block created under you! Total: " .. #SpawnedBlocks, 2)
    
    return block
end

-- Удаление всех созданных блоков
local function clearBlocks()
    for _, block in pairs(SpawnedBlocks) do
        if block then
            block:Destroy()
        end
    end
    SpawnedBlocks = {}
    notify("Blocks Cleared", "All spawned blocks removed!", 2)
end

-- // Core Features
local function setupSpeed()
    local hum = getHum()
    if hum then
        hum.WalkSpeed = Settings.Speed.Enabled and Settings.Speed.Value or 16
    end
end

local function setupJump()
    local hum = getHum()
    if hum then
        hum.JumpPower = Settings.Jump.Enabled and Settings.Jump.Value or 50
    end
end

local function setupNoClip()
    if Settings.NoClip.Enabled then
        spawn(function()
            while Settings.NoClip.Enabled do
                local char = getChar()
                if char then
                    for _, p in pairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide then
                            p.CanCollide = false
                        end
                    end
                end
                task.wait()
            end
        end)
    end
end

local function setupBHop()
    if Connections.BHop then Connections.BHop:Disconnect() end
    
    if Settings.BHop.Enabled then
        Connections.BHop = RunService.Heartbeat:Connect(function()
            local hum = getHum()
            local root = getRoot()
            if hum and root then
                if hum.MoveDirection.Magnitude > 0 and hum:GetState() == Enum.HumanoidStateType.Running then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

local function setupAutoRun()
    if Settings.AutoRun.Enabled then
        spawn(function()
            while Settings.AutoRun.Enabled do
                local hum = getHum()
                if hum then
                    hum.MoveDirection = Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
                end
                task.wait()
            end
        end)
    end
end

local function setupSpinBot()
    if Settings.SpinBot.Enabled then
        spawn(function()
            while Settings.SpinBot.Enabled do
                local root = getRoot()
                if root then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Settings.SpinBot.Speed), 0)
                end
                task.wait()
            end
        end)
    end
end

local function setupJesus()
    if Connections.Jesus then Connections.Jesus:Disconnect() end
    
    if Settings.Jesus.Enabled then
        Connections.Jesus = RunService.Heartbeat:Connect(function()
            local root = getRoot()
            local hum = getHum()
            if root and hum then
                local waterLevel = Workspace:FindFirstChild("Terrain") and Workspace.Terrain:GetWaterLevel(root.Position) or 0
                if root.Position.Y <= waterLevel + 3 then
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Velocity = Vector3.new(0, 50, 0)
                    bodyVelocity.MaxForce = Vector3.new(0, 4000, 0)
                    bodyVelocity.Parent = root
                    game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
                end
            end
        end)
    end
end

local function setupGlide()
    if Settings.Glide.Enabled then
        spawn(function()
            while Settings.Glide.Enabled do
                local hum = getHum()
                local root = getRoot()
                if hum and root then
                    if hum:GetState() == Enum.HumanoidStateType.Freefall then
                        root.Velocity = Vector3.new(root.Velocity.X, -10, root.Velocity.Z)
                    end
                end
                task.wait()
            end
        end)
    end
end

local function setupLowGravity()
    if Settings.LowGravity.Enabled then
        Workspace.Gravity = 30
    else
        Workspace.Gravity = 196.2
    end
end

local function setupWallWalk()
    if Connections.WallWalk then Connections.WallWalk:Disconnect() end
    
    if Settings.WallWalk.Enabled then
        Connections.WallWalk = RunService.Heartbeat:Connect(function()
            local root = getRoot()
            if root then
                local rayFront = raycast(root.Position, root.Position + root.CFrame.LookVector * 5)
                if rayFront then
                    local wallNormal = rayFront.Normal
                    local alignPosition = Instance.new("BodyPosition")
                    alignPosition.Position = rayFront.Position + wallNormal * 3
                    alignPosition.MaxForce = Vector3.new(4000, 4000, 4000)
                    alignPosition.Parent = root
                    game:GetService("Debris"):AddItem(alignPosition, 0.05)
                end
            end
        end)
    end
end

local function setupESP()
    for _, obj in pairs(ESPObjects) do
        for _, v in pairs(obj) do
            if v then v:Destroy() end
        end
    end
    ESPObjects = {}
    
    if not Settings.ESP.Enabled then return end
    
    local function addESP(player)
        if player == LocalPlayer then return end
        
        local function onChar(char)
            local head = char:WaitForChild("Head", 5)
            local hum = char:WaitForChild("Humanoid", 5)
            if not head or not hum then return end
            
            local objects = {}
            
            if Settings.ESP.Names then
                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 100, 0, 60)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                bb.Parent = head
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 0, 20)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.TextStrokeTransparency = 0
                nameLabel.Font = Enum.Font.SourceSansBold
                nameLabel.TextSize = 13
                nameLabel.Parent = bb
                
                if Settings.ESP.Distance then
                    local distLabel = Instance.new("TextLabel")
                    distLabel.Size = UDim2.new(1, 0, 0, 20)
                    distLabel.Position = UDim2.new(0, 0, 0, 20)
                    distLabel.BackgroundTransparency = 1
                    distLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
                    distLabel.TextStrokeTransparency = 0
                    distLabel.Font = Enum.Font.SourceSans
                    distLabel.TextSize = 11
                    distLabel.Parent = bb
                    
                    spawn(function()
                        while Settings.ESP.Enabled and char and char.Parent do
                            local myRoot = getRoot()
                            local theirRoot = char:FindFirstChild("HumanoidRootPart")
                            if myRoot and theirRoot then
                                distLabel.Text = string.format("%.0f studs", (myRoot.Position - theirRoot.Position).Magnitude)
                            end
                            task.wait(0.2)
                        end
                    end)
                end
                
                if Settings.ESP.Health then
                    local healthBar = Instance.new("Frame")
                    healthBar.Size = UDim2.new(1, 0, 0, 4)
                    healthBar.Position = UDim2.new(0, 0, 0, 40)
                    healthBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    healthBar.Parent = bb
                    
                    local healthFill = Instance.new("Frame")
                    healthFill.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
                    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    healthFill.Parent = healthBar
                    
                    hum.HealthChanged:Connect(function(health)
                        healthFill.Size = UDim2.new(health / hum.MaxHealth, 0, 1, 0)
                        if health < hum.MaxHealth * 0.3 then
                            healthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        elseif health < hum.MaxHealth * 0.6 then
                            healthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                        end
                    end)
                end
                
                objects.Billboard = bb
            end
            
            if Settings.ESP.Boxes then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = char:GetExtentsSize() + Vector3.new(0.5, 0.5, 0.5)
                box.Adornee = char
                box.Color3 = Color3.fromRGB(255, 255, 255)
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Transparency = 0.3
                box.Parent = char
                objects.Box = box
            end
            
            ESPObjects[player.UserId] = objects
        end
        
        if player.Character then
            onChar(player.Character)
        end
        player.CharacterAdded:Connect(onChar)
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        addESP(p)
    end
    Players.PlayerAdded:Connect(addESP)
end

local function setupFullBright()
    if Settings.FullBright.Enabled then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 9e9
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 500
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    end
end

local function setupChams()
    if Settings.Chams.Enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.ForceField
                        part.Color = Color3.fromRGB(0, 255, 255)
                    end
                end
            end
        end
    end
end

local function setupXRay()
    if Settings.XRay.Enabled then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") then
                obj.LocalTransparencyModifier = 0.7
            end
        end
    else
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier = 0
            end
        end
    end
end

local function setupAimbot()
    if AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
    end
    
    if not Settings.Aimbot.Enabled then return end
    
    AimbotConnection = RunService.Heartbeat:Connect(function()
        local target = getClosestPlayer(Settings.Aimbot.FOV)
        if not target then return end
        
        if Settings.Aimbot.TeamCheck and target.Team == LocalPlayer.Team then return end
        if Settings.Aimbot.VisibilityCheck and not isVisible(target) then return end
        
        local targetPart = target.Character and target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
        if not targetPart then return end
        
        local targetPos = targetPart.Position
        local camPos = Camera.CFrame.Position
        local lookAt = CFrame.new(camPos, targetPos)
        
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, Settings.Aimbot.Smoothness)
    end)
end

local function setupTriggerBot()
    if TriggerBotConnection then
        TriggerBotConnection:Disconnect()
        TriggerBotConnection = nil
    end
    
    if not Settings.TriggerBot.Enabled then return end
    
    TriggerBotConnection = RunService.Heartbeat:Connect(function()
        local target = getClosestPlayerToCursor()
        if target and target.Character then
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local tool = getChar() and getChar():FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("RemoteEvent") then
                    tool.RemoteEvent:FireServer()
                end
                task.wait(Settings.TriggerBot.Delay)
            end
        end
    end)
end

local function setupKillAura()
    if Settings.KillAura.Enabled then
        spawn(function()
            while Settings.KillAura.Enabled do
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local hum = player.Character:FindFirstChildOfClass("Humanoid")
                        local myRoot = getRoot()
                        local theirRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if hum and myRoot and theirRoot then
                            local dist = (myRoot.Position - theirRoot.Position).Magnitude
                            if dist <= Settings.KillAura.Range then
                                local args = {
                                    [1] = player,
                                    [2] = hum,
                                    [3] = 100
                                }
                                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                                    if remote:IsA("RemoteEvent") then
                                        pcall(function()
                                            remote:FireServer(unpack(args))
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end

local function setupAntiAfk()
    if Settings.AntiAfk.Enabled then
        spawn(function()
            while Settings.AntiAfk.Enabled do
                VirtualUser:CaptureController()
                VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
                task.wait(15)
            end
        end)
    end
end

local function setupGodMode()
    if Settings.GodMode.Enabled then
        spawn(function()
            while Settings.GodMode.Enabled do
                local hum = getHum()
                if hum then
                    hum.Health = hum.MaxHealth
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                end
                task.wait(0.1)
            end
        end)
    else
        local hum = getHum()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
end

local function setupInvisible()
    if Settings.Invisible.Enabled then
        spawn(function()
            while Settings.Invisible.Enabled do
                local char = getChar()
                if char then
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 1
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
    else
        local char = getChar()
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
    end
end

local function setupRainbow()
    if Settings.RainbowChar.Enabled then
        spawn(function()
            local hue = 0
            while Settings.RainbowChar.Enabled do
                local char = getChar()
                if char then
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Color = Color3.fromHSV(hue / 360, 1, 1)
                        end
                    end
                end
                hue = (hue + 1) % 360
                task.wait(0.05)
            end
        end)
    end
end

local function setupGiantMode()
    if Settings.GiantMode.Enabled then
        local char = getChar()
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Size = part.Size * 3
                end
            end
        end
    end
end

local function setupTinyMode()
    if Settings.TinyMode.Enabled then
        local char = getChar()
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Size = part.Size * 0.3
                end
            end
        end
    end
end

local function setupHeadless()
    if Settings.Headless.Enabled then
        local char = getChar()
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                head.Transparency = 1
                for _, v in pairs(head:GetChildren()) do
                    v:Destroy()
                end
            end
        end
    end
end

local function setupSpin()
    if Settings.Spin.Enabled then
        spawn(function()
            while Settings.Spin.Enabled do
                local root = getRoot()
                if root then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(15), 0)
                end
                task.wait()
            end
        end)
    end
end

local function setupFreeze()
    if Settings.Freeze.Enabled then
        local root = getRoot()
        if root then
            root.Anchored = true
        end
    else
        local root = getRoot()
        if root then
            root.Anchored = false
        end
    end
end

local function setupChatSpy()
    if Settings.ChatSpy.Enabled then
        spawn(function()
            while Settings.ChatSpy.Enabled do
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        pcall(function()
                            local chat = player.PlayerGui:FindFirstChild("Chat")
                            if chat then
                                -- Чтение чата
                            end
                        end)
                    end
                end
                task.wait(1)
            end
        end)
    end
end

local function setupSilentChat()
    if Settings.SilentChat.Enabled then
        spawn(function()
            while Settings.SilentChat.Enabled do
                task.wait(1)
            end
        end)
    end
end

local function teleportToCursor()
    local char = getChar()
    local root = getRoot()
    if not root then return end
    
    local target = Mouse.Hit
    local rayResult = raycast(target.Position + Vector3.new(0, 20, 0), target.Position + Vector3.new(0, -40, 0))
    local finalPos = target.Position + Vector3.new(0, 3, 0)
    if rayResult then
        finalPos = rayResult.Position + Vector3.new(0, 3, 0)
    end
    
    root.CFrame = CFrame.new(finalPos)
end

local function boostFPS()
    local Terrain = Workspace:FindFirstChild("Terrain")
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 0
    end
    
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    settings().Rendering.QualityLevel = 1
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("UnionOperation") or obj:IsA("MeshPart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
        end
    end
end

-- // GUI Creation
local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ProCheatHubFixed"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 620, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(0, 170, 255)
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(0, 300, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "⚡ PRO CHEAT HUB [FIXED]"
    TitleText.TextColor3 = Color3.fromRGB(0, 170, 255)
    TitleText.Font = Enum.Font.SourceSansBold
    TitleText.TextSize = 14
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(1, -28, 0, 4)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 12
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Tab Buttons Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 120, 1, -32)
    TabContainer.Position = UDim2.new(0, 0, 0, 32)
    TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 1)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer
    
    -- Content Pages Container
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -120, 1, -32)
    ContentFrame.Position = UDim2.new(0, 120, 0, 32)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    
    local pages = {}
    local tabButtons = {}
    
    local function switchTab(page, button)
        for _, p in pairs(pages) do
            p.Visible = false
        end
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            b.TextColor3 = Color3.fromRGB(140, 140, 140)
        end
        if page then page.Visible = true end
        if button then
            button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            button.TextColor3 = Color3.new(1, 1, 1)
        end
    end
    
    local function createTab(name, icon)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, 30)
        tabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        tabBtn.Text = " " .. icon .. " " .. name
        tabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
        tabBtn.Font = Enum.Font.SourceSans
        tabBtn.TextSize = 12
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.AutoButtonColor = false
        tabBtn.Parent = TabContainer
        
        table.insert(tabButtons, tabBtn)
        
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = false
        page.Parent = ContentFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 4)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page
        
        table.insert(pages, page)
        
        tabBtn.MouseButton1Click:Connect(function()
            switchTab(page, tabBtn)
        end)
        
        page.ChildAdded:Connect(function()
            task.wait()
            local total = 0
            for _, child in pairs(page:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                    total = total + child.Size.Y.Offset + 4
                end
            end
            page.CanvasSize = UDim2.new(0, 0, 0, total + 16)
        end)
        
        return page
    end
    
    -- Create Tabs
    local MovementPage = createTab("Movement", "🏃")
    local BlocksPage = createTab("Blocks", "🧱")
    local VisualPage = createTab("Visual", "👁️")
    local CombatPage = createTab("Combat", "⚔️")
    local WorldPage = createTab("World", "🌍")
    local CharacterPage = createTab("Character", "🎭")
    local MiscPage = createTab("Misc", "🔧")
    local SettingsPage = createTab("Settings", "⚙️")
    
    -- Activate first tab
    switchTab(pages[1], tabButtons[1])
    
    -- // UI Elements
    local function addToggle(parent, name, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 470, 0, 35)
        frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 350, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 38, 0, 20)
        btn.Position = UDim2.new(1, -48, 0.5, -10)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = frame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(1, 0)
        btnCorner.Parent = btn
        
        local state = default
        
        btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
            }):Play()
            if callback then callback(state) end
        end)
        
        return {
            SetState = function(s)
                state = s
                btn.BackgroundColor3 = s and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
            end
        }
    end
    
    local function addSlider(parent, name, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 470, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 180, 0, 18)
        label.Position = UDim2.new(0, 10, 0, 3)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0, 50, 0, 18)
        valLabel.Position = UDim2.new(1, -60, 0, 3)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(default)
        valLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        valLabel.Font = Enum.Font.SourceSansBold
        valLabel.TextSize = 11
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent = frame
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Size = UDim2.new(1, -20, 0, 4)
        sliderBar.Position = UDim2.new(0, 10, 0, 30)
        sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        sliderBar.BorderSizePixel = 0
        sliderBar.Parent = frame
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 2)
        barCorner.Parent = sliderBar
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        fill.BorderSizePixel = 0
        fill.Parent = sliderBar
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 2)
        fillCorner.Parent = fill
        
        local dragging = false
        
        local function update(input)
            local pos = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
            local percent = pos / sliderBar.AbsoluteSize.X
            local value = math.floor(min + (max - min) * percent + 0.5)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valLabel.Text = tostring(value)
            if callback then callback(value) end
        end
        
        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                update(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                update(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    
    local function addButton(parent, name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 470, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        btn.Text = name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            callback()
            btn.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
            task.wait(0.1)
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        end)
    end
    
    local function addLabel(parent, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 470, 0, 22)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(100, 100, 100)
        lbl.Font = Enum.Font.SourceSans
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.Parent = parent
    end
    
    -- // Movement Tab
    addLabel(MovementPage, "—— MOVEMENT ——")
    
    addToggle(MovementPage, "Flight", false, function(state)
        Settings.Flight.Enabled = state
        setupFlight()
    end)
    
    addSlider(MovementPage, "Flight Speed", 20, 300, 50, function(value)
        Settings.Flight.Speed = value
    end)
    
    addToggle(MovementPage, "Speed Boost", false, function(state)
        Settings.Speed.Enabled = state
        setupSpeed()
    end)
    
    addSlider(MovementPage, "Walk Speed", 16, 300, 32, function(value)
        Settings.Speed.Value = value
        if Settings.Speed.Enabled then setupSpeed() end
    end)
    
    addToggle(MovementPage, "Super Jump", false, function(state)
        Settings.Jump.Enabled = state
        setupJump()
    end)
    
    addSlider(MovementPage, "Jump Power", 50, 1000, 100, function(value)
        Settings.Jump.Value = value
        if Settings.Jump.Enabled then setupJump() end
    end)
    
    addToggle(MovementPage, "Infinite Jump", false, function(state)
        Settings.InfiniteJump.Enabled = state
    end)
    
    addToggle(MovementPage, "NoClip", false, function(state)
        Settings.NoClip.Enabled = state
        setupNoClip()
    end)
    
    addToggle(MovementPage, "Click TP (Ctrl+Click)", false, function(state)
        Settings.ClickTP.Enabled = state
    end)
    
    addToggle(MovementPage, "Bunny Hop", false, function(state)
        Settings.BHop.Enabled = state
        setupBHop()
    end)
    
    addToggle(MovementPage, "Auto Run", false, function(state)
        Settings.AutoRun.Enabled = state
        setupAutoRun()
    end)
    
    addToggle(MovementPage, "Spin Bot", false, function(state)
        Settings.SpinBot.Enabled = state
        setupSpinBot()
    end)
    
    addSlider(MovementPage, "Spin Speed", 1, 50, 10, function(value)
        Settings.SpinBot.Speed = value
    end)
    
    addToggle(MovementPage, "Jesus (Water Walk)", false, function(state)
        Settings.Jesus.Enabled = state
        setupJesus()
    end)
    
    addToggle(MovementPage, "Glide", false, function(state)
        Settings.Glide.Enabled = state
        setupGlide()
    end)
    
    addToggle(MovementPage, "Low Gravity", false, function(state)
        Settings.LowGravity.Enabled = state
        setupLowGravity()
    end)
    
    addToggle(MovementPage, "Wall Walk", false, function(state)
        Settings.WallWalk.Enabled = state
        setupWallWalk()
    end)
    
    -- // Blocks Tab
    addLabel(BlocksPage, "—— BLOCK SPAWNER ——")
    
    addLabel(BlocksPage, "Press NumPad1 to spawn block under you")
    addLabel(BlocksPage, "Press NumPad2 to clear all blocks")
    
    addButton(BlocksPage, "Spawn Block (NumPad1)", function()
        spawnBlockUnder()
    end)
    
    addButton(BlocksPage, "Clear All Blocks (NumPad2)", function()
        clearBlocks()
    end)
    
    addSlider(BlocksPage, "Block Size", 2, 50, 10, function(value)
        Settings.BlockSpawn.Size = value
    end)
    
    -- Материалы для блока
    local materials = {"SmoothPlastic", "Wood", "Brick", "Concrete", "Metal", "Glass", "Ice", "Neon", "Marble"}
    for _, mat in pairs(materials) do
        addButton(BlocksPage, "Material: " .. mat, function()
            Settings.BlockSpawn.Material = mat
            notify("Block Material", "Set to " .. mat, 1.5)
        end)
    end
    
    -- Цвета блока
    local colors = {
        {"White", Color3.fromRGB(255, 255, 255)},
        {"Red", Color3.fromRGB(255, 0, 0)},
        {"Blue", Color3.fromRGB(0, 0, 255)},
        {"Green", Color3.fromRGB(0, 255, 0)},
        {"Yellow", Color3.fromRGB(255, 255, 0)},
        {"Purple", Color3.fromRGB(128, 0, 128)},
        {"Black", Color3.fromRGB(0, 0, 0)}
    }
    
    for _, colorData in pairs(colors) do
        addButton(BlocksPage, "Color: " .. colorData[1], function()
            Settings.BlockSpawn.Color = colorData[2]
            notify("Block Color", "Set to " .. colorData[1], 1.5)
        end)
    end
    
    -- // Visual Tab
    addLabel(VisualPage, "—— VISUAL ——")
    
    addToggle(VisualPage, "Player ESP", false, function(state)
        Settings.ESP.Enabled = state
        setupESP()
    end)
    
    addToggle(VisualPage, "ESP Boxes", true, function(state)
        Settings.ESP.Boxes = state
        setupESP()
    end)
    
    addToggle(VisualPage, "ESP Names", true, function(state)
        Settings.ESP.Names = state
        setupESP()
    end)
    
    addToggle(VisualPage, "ESP Distance", true, function(state)
        Settings.ESP.Distance = state
        setupESP()
    end)
    
    addToggle(VisualPage, "ESP Health", true, function(state)
        Settings.ESP.Health = state
        setupESP()
    end)
    
    addToggle(VisualPage, "Full Bright", false, function(state)
        Settings.FullBright.Enabled = state
        setupFullBright()
    end)
    
    addSlider(VisualPage, "Field of View", 30, 120, 70, function(value)
        Settings.FOV = value
        Camera.FieldOfView = value
    end)
    
    addToggle(VisualPage, "No Fog", false, function(state)
        Settings.NoFog.Enabled = state
        if state then
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 9e9
        else
            Lighting.FogEnd = 500
            Lighting.FogStart = 0
        end
    end)
    
    addToggle(VisualPage, "Chams", false, function(state)
        Settings.Chams.Enabled = state
        setupChams()
    end)
    
    addToggle(VisualPage, "X-Ray", false, function(state)
        Settings.XRay.Enabled = state
        setupXRay()
    end)
    
    -- // Combat Tab
    addLabel(CombatPage, "—— COMBAT ——")
    
    addToggle(CombatPage, "Aimbot", false, function(state)
        Settings.Aimbot.Enabled = state
        setupAimbot()
    end)
    
    addSlider(CombatPage, "Aimbot FOV", 10, 360, 100, function(value)
        Settings.Aimbot.FOV = value
    end)
    
    addSlider(CombatPage, "Aimbot Smoothness", 0.1, 1, 0.5, function(value)
        Settings.Aimbot.Smoothness = value
    end)
    
    addToggle(CombatPage, "Trigger Bot", false, function(state)
        Settings.TriggerBot.Enabled = state
        setupTriggerBot()
    end)
    
    addToggle(CombatPage, "Silent Aim", false, function(state)
        Settings.SilentAim.Enabled = state
    end)
    
    addToggle(CombatPage, "Kill Aura", false, function(state)
        Settings.KillAura.Enabled = state
        setupKillAura()
    end)
    
    addSlider(CombatPage, "Kill Aura Range", 5, 50, 20, function(value)
        Settings.KillAura.Range = value
    end)
    
    addToggle(CombatPage, "Reach", false, function(state)
        Settings.Reach.Enabled = state
    end)
    
    addToggle(CombatPage, "No Recoil", false, function(state)
        Settings.NoRecoil.Enabled = state
    end)
    
    addToggle(CombatPage, "No Spread", false, function(state)
        Settings.NoSpread.Enabled = state
    end)
    
    addToggle(CombatPage, "Instant Reload", false, function(state)
        Settings.InstantReload.Enabled = state
    end)
    
    addToggle(CombatPage, "Infinite Ammo", false, function(state)
        Settings.InfiniteAmmo.Enabled = state
    end)
    
    addToggle(CombatPage, "Rapid Fire", false, function(state)
        Settings.RapidFire.Enabled = state
    end)
    
    -- // World Tab
    addLabel(WorldPage, "—— WORLD ——")
    
    addButton(WorldPage, "Teleport to Cursor", function()
        teleportToCursor()
        notify("Teleport", "Teleported to cursor!", 1.5)
    end)
    
    addButton(WorldPage, "FPS Booster", function()
        boostFPS()
        notify("Performance", "FPS boosted!", 2)
    end)
    
    addToggle(WorldPage, "Anti-AFK", false, function(state)
        Settings.AntiAfk.Enabled = state
        setupAntiAfk()
    end)
    
    addToggle(WorldPage, "Time Changer", false, function(state)
        Settings.TimeChanger.Enabled = state
    end)
    
    addSlider(WorldPage, "Time", 0, 24, 14, function(value)
        if Settings.TimeChanger.Enabled then
            Lighting.ClockTime = value
        end
    end)
    
    addToggle(WorldPage, "Gravity Changer", false, function(state)
        Settings.Gravity.Enabled = state
        if state then
            Workspace.Gravity = Settings.Gravity.Value
        else
            Workspace.Gravity = 196.2
        end
    end)
    
    addSlider(WorldPage, "Gravity", 0, 500, 196.2, function(value)
        Settings.Gravity.Value = value
        if Settings.Gravity.Enabled then
            Workspace.Gravity = value
        end
    end)
    
    -- // Character Tab
    addLabel(CharacterPage, "—— CHARACTER ——")
    
    addToggle(CharacterPage, "God Mode", false, function(state)
        Settings.GodMode.Enabled = state
        setupGodMode()
    end)
    
    addToggle(CharacterPage, "Invisible", false, function(state)
        Settings.Invisible.Enabled = state
        setupInvisible()
    end)
    
    addToggle(CharacterPage, "Freeze", false, function(state)
        Settings.Freeze.Enabled = state
        setupFreeze()
    end)
    
    addToggle(CharacterPage, "Giant Mode", false, function(state)
        Settings.GiantMode.Enabled = state
        setupGiantMode()
    end)
    
    addToggle(CharacterPage, "Tiny Mode", false, function(state)
        Settings.TinyMode.Enabled = state
        setupTinyMode()
    end)
    
    addToggle(CharacterPage, "Rainbow Character", false, function(state)
        Settings.RainbowChar.Enabled = state
        setupRainbow()
    end)
    
    addToggle(CharacterPage, "Spin", false, function(state)
        Settings.Spin.Enabled = state
        setupSpin()
    end)
    
    addToggle(CharacterPage, "Headless", false, function(state)
        Settings.Headless.Enabled = state
        setupHeadless()
    end)
    
    addButton(CharacterPage, "Respawn", function()
        local hum = getHum()
        if hum then hum.Health = 0 end
    end)
    
    -- // Misc Tab
    addLabel(MiscPage, "—— MISCELLANEOUS ——")
    
    addToggle(MiscPage, "Stream Snipe", false, function(state)
        Settings.StreamSnipe.Enabled = state
    end)
    
    addToggle(MiscPage, "Auto Reconnect", false, function(state)
        Settings.AutoReconnect.Enabled = state
    end)
    
    addToggle(MiscPage, "Chat Spy", false, function(state)
        Settings.ChatSpy.Enabled = state
        setupChatSpy()
    end)
    
    addToggle(MiscPage, "Silent Chat", false, function(state)
        Settings.SilentChat.Enabled = state
        setupSilentChat()
    end)
    
    -- // Settings Tab
    addLabel(SettingsPage, "—— SETTINGS ——")
    
    addButton(SettingsPage, "Rejoin Server", function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    
    addButton(SettingsPage, "Server Hop", function()
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            ))
        end)
        if success and result then
            for _, s in ipairs(result.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
                    break
                end
            end
        end
        notify("Server Hop", "Looking for new server...", 2)
    end)
    
    addButton(SettingsPage, "Copy Game Link", function()
        setclipboard("https://www.roblox.com/games/" .. game.PlaceId .. "/")
        notify("Link", "Copied!", 1.5)
    end)
    
    -- // Drag
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return ScreenGui
end

-- // KEYBINDS - ТОЛЬКО NUMPAD КЛАВИШИ
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local key = input.KeyCode
    
    -- NumPad1 - Создать блок под собой
    if key == Enum.KeyCode.KeypadOne then
        spawnBlockUnder()
        
    -- NumPad2 - Очистить все блоки
    elseif key == Enum.KeyCode.KeypadTwo then
        clearBlocks()
        
    -- NumPad3 - Телепорт к курсору
    elseif key == Enum.KeyCode.KeypadThree then
        teleportToCursor()
        notify("Teleport", "Teleported!", 1)
        
    -- RightShift - Показать/скрыть GUI
    elseif key == Enum.KeyCode.RightShift then
        local gui = game:GetService("CoreGui"):FindFirstChild("ProCheatHubFixed")
        if gui then gui.Enabled = not gui.Enabled end
    end
end)

-- // Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump.Enabled then
        local hum = getHum()
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- // Click TP
Mouse.Button1Down:Connect(function()
    if Settings.ClickTP.Enabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        teleportToCursor()
    end
end)

-- // Character Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    
    if Settings.Speed.Enabled then setupSpeed() end
    if Settings.Jump.Enabled then setupJump() end
    if Settings.Flight.Enabled then setupFlight() end
    if Settings.NoClip.Enabled then setupNoClip() end
    if Settings.BHop.Enabled then setupBHop() end
    if Settings.GodMode.Enabled then setupGodMode() end
    if Settings.Invisible.Enabled then setupInvisible() end
    if Settings.GiantMode.Enabled then setupGiantMode() end
    if Settings.TinyMode.Enabled then setupTinyMode() end
    if Settings.Headless.Enabled then setupHeadless() end
    if Settings.Spin.Enabled then setupSpin() end
    if Settings.Freeze.Enabled then setupFreeze() end
    if Settings.RainbowChar.Enabled then setupRainbow() end
    if Settings.Glide.Enabled then setupGlide() end
    if Settings.LowGravity.Enabled then setupLowGravity() end
    if Settings.Jesus.Enabled then setupJesus() end
    if Settings.WallWalk.Enabled then setupWallWalk() end
end)

-- // Initialize
createGUI()

-- Инструкция при запуске
notify("PRO CHEAT HUB FIXED", "NumPad1: Spawn Block | NumPad2: Clear Blocks | NumPad3: Teleport", 6)