--[[
    PRO CHEAT HUB v1.2.1
    by mcherenkovYT
]]

-- Services
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
local TextChatService = game:GetService("TextChatService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Anti-Cheat Bypass
local function setupBypass()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "FireServer" then
            local name = tostring(self)
            if name:find("Kick") or name:find("Ban") then return nil end
        end
        if method == "Kick" or method == "kick" then return nil end
        return oldNamecall(self, ...)
    end)
    
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if tostring(self) == "Humanoid" then
            if key == "WalkSpeed" or key == "JumpPower" or key == "MaxHealth" or key == "Health" then
                return oldIndex(self, key)
            end
        end
        if key == "Detected" or key == "Checking" or key == "Verify" then return false end
        return oldIndex(self, key)
    end)
end
pcall(setupBypass)

-- Settings
local Settings = {
    Flight = {Enabled = false, Speed = 50},
    Speed = {Enabled = false, Value = 32},
    Jump = {Enabled = false, Value = 100},
    InfiniteJump = {Enabled = false},
    NoClip = {Enabled = false},
    ClickTP = {Enabled = false},
    BlockSpawn = {Enabled = false, Size = 10, Material = "SmoothPlastic", Color = Color3.fromRGB(255, 255, 255)},
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        Tracers = false,
        Snaplines = false,
        Skeletons = false,
        HeadDot = false,
        Glow = false,
        ShowWeapon = false,
        TeamCheck = false,
        TeamColor = false,
        Rainbow = false,
        VisibleOnly = false,
        TextOutline = true,
        MaxDistance = 500,
        BoxColor = Color3.fromRGB(255, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        NameSize = 13,
        DistanceColor = Color3.fromRGB(200, 200, 200),
        HealthColor = Color3.fromRGB(0, 255, 0),
        TracerColor = Color3.fromRGB(255, 255, 255),
        TracerThickness = 1,
        TracerOrigin = "Bottom",
        SnaplineColor = Color3.fromRGB(255, 255, 255),
        SnaplineThickness = 1,
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        HeadDotColor = Color3.fromRGB(255, 0, 0),
        HeadDotSize = 8,
        GlowColor = Color3.fromRGB(0, 170, 255),
        GlowTransparency = 0.7
    },
    FullBright = {Enabled = false},
    FOV = 70,
    NoFog = {Enabled = false},
    Chams = {Enabled = false},
    XRay = {Enabled = false},
    Aimbot = {Enabled = false, FOV = 100, Smoothness = 0.5, TargetPart = "Head", TeamCheck = false, VisibilityCheck = true},
    TriggerBot = {Enabled = false, Delay = 0.1},
    SilentAim = {Enabled = false, FOV = 50},
    KillAura = {Enabled = false, Range = 20},
    AntiAfk = {Enabled = false},
    TimeChanger = {Enabled = false, Time = 14},
    Gravity = {Enabled = false, Value = 196.2}
}

local FlightObjects = {}
local ESPObjects = {}
local ESPConnections = {}
local AimbotConnection = nil
local TriggerBotConnection = nil
local SpawnedBlocks = {}
local RainbowHue = 0

-- Chat System
local CustomChatMessages = {}
local ChatRemoteName = "ProHubChat_v121"

local ChatRemote = ReplicatedStorage:FindFirstChild(ChatRemoteName)
if not ChatRemote then
    ChatRemote = Instance.new("RemoteEvent")
    ChatRemote.Name = ChatRemoteName
    ChatRemote.Parent = ReplicatedStorage
end

ChatRemote.OnClientEvent:Connect(function(senderName, message, senderUserId)
    if senderUserId == LocalPlayer.UserId then return end
    table.insert(CustomChatMessages, {Name = senderName, Message = message, Time = os.time(), UserId = senderUserId})
    if #CustomChatMessages > 50 then table.remove(CustomChatMessages, 1) end
    notify(senderName, message, 4)
end)

local function sendCustomChatMessage(message)
    if not message or message == "" then return end
    ChatRemote:FireAllClients(LocalPlayer.Name, message, LocalPlayer.UserId)
    table.insert(CustomChatMessages, {Name = LocalPlayer.Name, Message = message, Time = os.time(), UserId = LocalPlayer.UserId})
    if #CustomChatMessages > 50 then table.remove(CustomChatMessages, 1) end
end

-- Utility Functions
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

local function getRainbowColor()
    RainbowHue = (RainbowHue + 1) % 360
    return Color3.fromHSV(RainbowHue / 360, 1, 1)
end

local function notify(title, text, dur)
    spawn(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "ProHubNotify"
        sg.Parent = game:GetService("CoreGui")
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 280, 0, 65)
        f.Position = UDim2.new(1, 0, 0.75, 0)
        f.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        f.BackgroundTransparency = 0.1
        f.BorderSizePixel = 0
        f.Parent = sg
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = f
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 180, 255)
        stroke.Thickness = 1
        stroke.Parent = f
        
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, 0, 0, 24)
        tl.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        tl.Text = "  " .. title
        tl.TextColor3 = Color3.fromRGB(255, 255, 255)
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 12
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Parent = f
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, -16, 0, 41)
        txt.Position = UDim2.new(0, 8, 0, 24)
        txt.BackgroundTransparency = 1
        txt.Text = text
        txt.TextColor3 = Color3.fromRGB(220, 220, 220)
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 11
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Parent = f
        
        f:TweenPosition(UDim2.new(1, -292, 0.75, 0), "Out", "Quart", 0.3)
        task.wait(dur or 2.5)
        f:TweenPosition(UDim2.new(1, 0, 0.75, 0), "In", "Quart", 0.3)
        task.wait(0.3)
        sg:Destroy()
    end)
end

local function raycast(from, to, ignore)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignore and {ignore} or {getChar()}
    return Workspace:Raycast(from, (to - from).Unit * (to - from).Magnitude, params)
end

-- Flight
local function setupFlight()
    local char = getChar()
    if not char then return end
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end
    
    if FlightObjects.Connection then FlightObjects.Connection:Disconnect(); FlightObjects.Connection = nil end
    if FlightObjects.Gyro then FlightObjects.Gyro:Destroy(); FlightObjects.Gyro = nil end
    if FlightObjects.Velocity then FlightObjects.Velocity:Destroy(); FlightObjects.Velocity = nil end
    
    if not Settings.Flight.Enabled then hum.PlatformStand = false; return end
    
    hum.PlatformStand = true
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 10000
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root
    FlightObjects.Gyro = bodyGyro
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root
    FlightObjects.Velocity = bodyVelocity
    
    FlightObjects.Connection = RunService.Heartbeat:Connect(function()
        if not Settings.Flight.Enabled then return end
        if not root or not hum or hum.Health <= 0 then setupFlight(); return end
        
        local moveVector = Vector3.zero
        local cf = Camera.CFrame.LookVector
        local cr = Camera.CFrame.RightVector
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector += cf end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector -= cf end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector -= cr end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector += cr end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector -= Vector3.new(0, 1, 0) end
        
        local mult = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 2.5 or 1
        
        if moveVector.Magnitude > 0 then
            bodyVelocity.Velocity = moveVector.Unit * Settings.Flight.Speed * mult
        else
            bodyVelocity.Velocity = Vector3.zero
        end
        
        bodyGyro.CFrame = CFrame.new(root.Position, root.Position + cf)
    end)
end

-- Block Spawn
local function spawnBlockUnder()
    local root = getRoot()
    if not root then return end
    
    if #SpawnedBlocks > 50 then
        for i = 1, 10 do
            local old = table.remove(SpawnedBlocks, 1)
            if old then old:Destroy() end
        end
    end
    
    local block = Instance.new("Part")
    block.Name = "SpawnedBlock_" .. os.time()
    block.Size = Vector3.new(Settings.BlockSpawn.Size, 2, Settings.BlockSpawn.Size)
    block.Position = root.Position - Vector3.new(0, 5, 0)
    block.Anchored = true
    block.CanCollide = true
    block.Material = Enum.Material[Settings.BlockSpawn.Material]
    block.Color = Settings.BlockSpawn.Color
    block.Parent = Workspace
    
    table.insert(SpawnedBlocks, block)
    notify("Block", "Spawned! Total: " .. #SpawnedBlocks, 2)
    return block
end

local function clearBlocks()
    for _, b in pairs(SpawnedBlocks) do if b then b:Destroy() end end
    SpawnedBlocks = {}
    notify("Blocks", "Cleared!", 2)
end

-- Movement
local function setupSpeed()
    local hum = getHum()
    if hum then hum.WalkSpeed = Settings.Speed.Enabled and Settings.Speed.Value or 16 end
end

local function setupJump()
    local hum = getHum()
    if hum then hum.JumpPower = Settings.Jump.Enabled and Settings.Jump.Value or 50 end
end

local function setupNoClip()
    if Settings.NoClip.Enabled then
        spawn(function()
            while Settings.NoClip.Enabled do
                local char = getChar()
                if char then
                    for _, p in pairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                    end
                end
                task.wait()
            end
        end)
    end
end

-- Combat
local function getClosestPlayer(range)
    local closest, shortest = nil, range or math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = getRoot()
            if hum and hum.Health > 0 and root and myRoot then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < shortest then shortest = dist; closest = p end
            end
        end
    end
    return closest
end

local function getClosestPlayerToCursor()
    local closest, shortest = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local sp, os = Camera:WorldToViewportPoint(head.Position)
                if os then
                    local dist = (Vector2.new(sp.X, sp.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < shortest then shortest = dist; closest = p end
                end
            end
        end
    end
    return closest
end

local function isVisible(target)
    local myRoot = getRoot()
    local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return false end
    local ray = raycast(myRoot.Position, tRoot.Position, getChar())
    if ray then return ray.Instance:IsDescendantOf(target.Character) end
    return false
end

local function setupAimbot()
    if AimbotConnection then AimbotConnection:Disconnect(); AimbotConnection = nil end
    if not Settings.Aimbot.Enabled then return end
    
    AimbotConnection = RunService.Heartbeat:Connect(function()
        local target = getClosestPlayer(Settings.Aimbot.FOV)
        if not target then return end
        if Settings.Aimbot.TeamCheck and target.Team == LocalPlayer.Team then return end
        if Settings.Aimbot.VisibilityCheck and not isVisible(target) then return end
        
        local tp = target.Character and target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
        if not tp then return end
        
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, tp.Position), Settings.Aimbot.Smoothness)
    end)
end

local function setupTriggerBot()
    if TriggerBotConnection then TriggerBotConnection:Disconnect(); TriggerBotConnection = nil end
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
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        local myRoot = getRoot()
                        local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        if hum and myRoot and tRoot then
                            if (myRoot.Position - tRoot.Position).Magnitude <= Settings.KillAura.Range then
                                for _, r in pairs(ReplicatedStorage:GetDescendants()) do
                                    if r:IsA("RemoteEvent") then pcall(function() r:FireServer(p, hum, 100) end) end
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

-- ESP System
local function setupESP()
    for _, objList in pairs(ESPObjects) do
        for _, obj in pairs(objList) do
            if type(obj) == "table" then
                for _, v in pairs(obj) do
                    if v and v.Remove then v:Remove() elseif v and v:Destroy then v:Destroy() end
                end
            elseif obj then
                if obj.Remove then obj:Remove() elseif obj:Destroy then obj:Destroy() end
            end
        end
    end
    ESPObjects = {}
    
    for _, conn in pairs(ESPConnections) do
        if conn then conn:Disconnect() end
    end
    ESPConnections = {}
    
    if not Settings.ESP.Enabled then return end
    
    local function addESP(player)
        if player == LocalPlayer then return end
        if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then return end
        
        ESPObjects[player.UserId] = {}
        
        local function onCharacter(char)
            local drawings = {}
            local head = char:WaitForChild("Head", 5)
            local humanoid = char:WaitForChild("Humanoid", 5)
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            
            if not head or not humanoid then return end
            
            local color = Settings.ESP.BoxColor
            if Settings.ESP.TeamColor and player.Team then
                color = player.Team.TeamColor.Color
            end
            
            -- Billboard GUI
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 200, 0, 80)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Enabled = true
            billboard.Parent = head
            table.insert(drawings, billboard)
            
            -- 3D Box
            if Settings.ESP.Boxes then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(2, 3, 1)
                box.Adornee = char
                box.Color3 = color
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Transparency = 0.3
                box.Parent = char
                table.insert(drawings, box)
            end
            
            -- Glow
            if Settings.ESP.Glow then
                local glow = Instance.new("Highlight")
                glow.FillColor = Settings.ESP.GlowColor
                glow.FillTransparency = Settings.ESP.GlowTransparency
                glow.OutlineColor = Settings.ESP.GlowColor
                glow.OutlineTransparency = Settings.ESP.GlowTransparency
                glow.Enabled = true
                glow.Parent = char
                table.insert(drawings, glow)
            end
            
            -- Name
            if Settings.ESP.Names then
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 0, 20)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Settings.ESP.NameColor
                nameLabel.TextStrokeTransparency = Settings.ESP.TextOutline and 0 or 1
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = Settings.ESP.NameSize
                nameLabel.Parent = billboard
            end
            
            -- Distance
            if Settings.ESP.Distance then
                local distLabel = Instance.new("TextLabel")
                distLabel.Size = UDim2.new(1, 0, 0, 18)
                distLabel.Position = UDim2.new(0, 0, 0, Settings.ESP.Names and 20 or 0)
                distLabel.BackgroundTransparency = 1
                distLabel.Text = "0m"
                distLabel.TextColor3 = Settings.ESP.DistanceColor
                distLabel.TextStrokeTransparency = Settings.ESP.TextOutline and 0 or 1
                distLabel.Font = Enum.Font.Gotham
                distLabel.TextSize = Settings.ESP.NameSize - 2
                distLabel.Name = "Distance"
                distLabel.Parent = billboard
            end
            
            -- Health
            if Settings.ESP.Health then
                local healthBar = Instance.new("Frame")
                healthBar.Size = UDim2.new(1, 0, 0, 4)
                healthBar.Position = UDim2.new(0, 0, 0, 40)
                healthBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                healthBar.Parent = billboard
                
                local healthFill = Instance.new("Frame")
                healthFill.Size = UDim2.new(1, 0, 1, 0)
                healthFill.BackgroundColor3 = Settings.ESP.HealthColor
                healthFill.Name = "HealthFill"
                healthFill.Parent = healthBar
            end
            
            -- Weapon
            if Settings.ESP.ShowWeapon then
                local weaponLabel = Instance.new("TextLabel")
                weaponLabel.Size = UDim2.new(1, 0, 0, 18)
                weaponLabel.Position = UDim2.new(0, 0, 0, 48)
                weaponLabel.BackgroundTransparency = 1
                weaponLabel.Text = ""
                weaponLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                weaponLabel.TextStrokeTransparency = 0
                weaponLabel.Font = Enum.Font.Gotham
                weaponLabel.TextSize = Settings.ESP.NameSize - 3
                weaponLabel.Name = "Weapon"
                weaponLabel.Visible = false
                weaponLabel.Parent = billboard
            end
            
            ESPObjects[player.UserId] = drawings
            
            -- Update loop
            local connection = RunService.Heartbeat:Connect(function()
                if not Settings.ESP.Enabled then
                    if billboard then billboard.Enabled = false end
                    for _, d in pairs(drawings) do
                        if d and d.Visible ~= nil then d.Visible = false end
                        if d and d.Enabled ~= nil then d.Enabled = false end
                    end
                    return
                end
                
                if not player.Character or player.Character ~= char then return end
                if not head or not head.Parent or not rootPart or not rootPart.Parent then return end
                
                local myRoot = getRoot()
                if myRoot then
                    local dist = (rootPart.Position - myRoot.Position).Magnitude
                    if dist > Settings.ESP.MaxDistance then
                        if billboard then billboard.Enabled = false end
                        for _, d in pairs(drawings) do
                            if d and d.Visible ~= nil then d.Visible = false end
                            if d and d.Enabled ~= nil then d.Enabled = false end
                        end
                        return
                    end
                end
                
                if Settings.ESP.VisibleOnly and not isVisible(player) then
                    if billboard then billboard.Enabled = false end
                    for _, d in pairs(drawings) do
                        if d and d.Visible ~= nil then d.Visible = false end
                        if d and d.Enabled ~= nil then d.Enabled = false end
                    end
                    return
                end
                
                if humanoid.Health <= 0 then
                    if billboard then billboard.Enabled = false end
                    return
                end
                
                if Settings.ESP.Rainbow then color = getRainbowColor() end
                
                if billboard then billboard.Enabled = true end
                
                -- Update distance
                if Settings.ESP.Distance and myRoot then
                    local distLabel = billboard:FindFirstChild("Distance")
                    if distLabel then
                        distLabel.Text = math.floor((rootPart.Position - myRoot.Position).Magnitude) .. "m"
                    end
                end
                
                -- Update health
                if Settings.ESP.Health then
                    local healthBar = billboard:FindFirstChild("Frame")
                    if healthBar then
                        local healthFill = healthBar:FindFirstChild("HealthFill")
                        if healthFill then
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                            local hc = Color3.fromHSV(healthPercent * 0.33, 1, 1)
                            healthFill.BackgroundColor3 = hc
                        end
                    end
                end
                
                -- Update box color
                if Settings.ESP.Boxes then
                    for _, d in pairs(drawings) do
                        if d and d:IsA("BoxHandleAdornment") then d.Color3 = color end
                    end
                end
                
                -- Update weapon
                if Settings.ESP.ShowWeapon then
                    local weaponLabel = billboard:FindFirstChild("Weapon")
                    if weaponLabel then
                        local tool = char:FindFirstChildOfClass("Tool")
                        weaponLabel.Text = tool and "[" .. tool.Name .. "]" or ""
                        weaponLabel.Visible = tool ~= nil
                    end
                end
            end)
            
            ESPConnections[player.UserId] = connection
        end
        
        if player.Character then onCharacter(player.Character) end
        player.CharacterAdded:Connect(onCharacter)
    end
    
    for _, p in pairs(Players:GetPlayers()) do addESP(p) end
    Players.PlayerAdded:Connect(addESP)
    
    Players.PlayerRemoving:Connect(function(player)
        if ESPObjects[player.UserId] then
            for _, d in pairs(ESPObjects[player.UserId]) do
                if d and d.Remove then d:Remove() end
                if d and d:Destroy then d:Destroy() end
            end
            ESPObjects[player.UserId] = nil
        end
        if ESPConnections[player.UserId] then
            ESPConnections[player.UserId]:Disconnect()
            ESPConnections[player.UserId] = nil
        end
    end)
end

-- Visual
local function setupFullBright()
    if Settings.FullBright.Enabled then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.FogEnd = 9e9
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.Brightness = 1
        Lighting.FogEnd = 500
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    end
end

local function setupChams()
    if Settings.Chams.Enabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, part in pairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.Material = Enum.Material.ForceField; part.Color = Color3.fromRGB(0, 255, 255) end
                end
            end
        end
    end
end

local function setupXRay()
    if Settings.XRay.Enabled then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") then obj.LocalTransparencyModifier = 0.7 end
        end
    else
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then obj.LocalTransparencyModifier = 0 end
        end
    end
end

-- World
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

local function teleportToCursor()
    local root = getRoot()
    if not root then return end
    local target = Mouse.Hit
    local ray = raycast(target.Position + Vector3.new(0, 20, 0), target.Position + Vector3.new(0, -40, 0))
    local finalPos = target.Position + Vector3.new(0, 3, 0)
    if ray then finalPos = ray.Position + Vector3.new(0, 3, 0) end
    root.CFrame = CFrame.new(finalPos)
end

local function boostFPS()
    local Terrain = Workspace:FindFirstChild("Terrain")
    if Terrain then Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0; Terrain.WaterReflectance = 0; Terrain.WaterTransparency = 0 end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    settings().Rendering.QualityLevel = 1
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("UnionOperation") or obj:IsA("MeshPart") then
            obj.Material = Enum.Material.SmoothPlastic; obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then obj:Destroy() end
    end
end

-- GUI
local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ProCheatHub"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    MainFrame.BackgroundTransparency = 0.08
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 8); MainCorner.Parent = MainFrame
    local MainStroke = Instance.new("UIStroke"); MainStroke.Color = Color3.fromRGB(0, 180, 255); MainStroke.Thickness = 1.2; MainStroke.Parent = MainFrame
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 34)
    TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TitleBar.BackgroundTransparency = 0.05
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner"); TitleCorner.CornerRadius = UDim.new(0, 8); TitleCorner.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(0, 280, 1, 0)
    TitleText.Position = UDim2.new(0, 12, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "PRO CHEAT HUB v1.2.1"
    TitleText.TextColor3 = Color3.fromRGB(0, 180, 255)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 13
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(1, -28, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 45, 45)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 12
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner"); CloseCorner.CornerRadius = UDim.new(0, 5); CloseCorner.Parent = CloseButton
    CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 125, 1, -34)
    TabContainer.Position = UDim2.new(0, 3, 0, 38)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout"); TabList.Padding = UDim.new(0, 3); TabList.SortOrder = Enum.SortOrder.LayoutOrder; TabList.Parent = TabContainer
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -132, 1, -42)
    ContentFrame.Position = UDim2.new(0, 129, 0, 38)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    
    local pages = {}
    local tabButtons = {}
    
    local function switchTab(page, button)
        for _, p in pairs(pages) do p.Visible = false end
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            b.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        if page then page.Visible = true end
        if button then
            button.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    
    local function createTab(name, icon)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, 30)
        tabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        tabBtn.BackgroundTransparency = 0.05
        tabBtn.Text = " " .. icon .. "  " .. name
        tabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 11
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.AutoButtonColor = false
        tabBtn.Parent = TabContainer
        
        local tabCorner = Instance.new("UICorner"); tabCorner.CornerRadius = UDim.new(0, 7); tabCorner.Parent = tabBtn
        local tabStroke = Instance.new("UIStroke"); tabStroke.Color = Color3.fromRGB(0, 140, 200); tabStroke.Thickness = 0.7; tabStroke.Parent = tabBtn
        
        table.insert(tabButtons, tabBtn)
        
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = false
        page.Parent = ContentFrame
        
        local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 4); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = page
        
        table.insert(pages, page)
        tabBtn.MouseButton1Click:Connect(function() switchTab(page, tabBtn) end)
        
        page.ChildAdded:Connect(function()
            task.wait()
            local total = 0
            for _, child in pairs(page:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                    total = total + child.Size.Y.Offset + 4
                end
            end
            page.CanvasSize = UDim2.new(0, 0, 0, total + 10)
        end)
        
        return page
    end
    
    local MovementPage = createTab("Movement", "W")
    local BlocksPage = createTab("Blocks", "B")
    local VisualPage = createTab("Visual", "V")
    local CombatPage = createTab("Combat", "C")
    local WorldPage = createTab("World", "E")
    local ChatPage = createTab("Hub Chat", "H")
    local SettingsPage = createTab("Settings", "S")
    local InstructPage = createTab("Info", "?")
    
    switchTab(pages[1], tabButtons[1])
    
    local function addToggle(parent, name, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 450, 0, 33)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        frame.BackgroundTransparency = 0.05
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 5); corner.Parent = frame
        local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(0, 140, 200); stroke.Thickness = 0.7; stroke.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 320, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(230, 230, 230)
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 40, 0, 20)
        btn.Position = UDim2.new(1, -50, 0.5, -10)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(55, 55, 55)
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = frame
        
        local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(1, 0); btnCorner.Parent = btn
        
        local state = default
        
        btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(55, 55, 55)}):Play()
            if callback then callback(state) end
        end)
        
        return {SetState = function(s) state = s; btn.BackgroundColor3 = s and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(55, 55, 55) end}
    end
    
    local function addSlider(parent, name, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 450, 0, 48)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        frame.BackgroundTransparency = 0.05
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 5); corner.Parent = frame
        local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(0, 140, 200); stroke.Thickness = 0.7; stroke.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 200, 0, 16)
        label.Position = UDim2.new(0, 10, 0, 3)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.Gotham
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0, 50, 0, 16)
        valLabel.Position = UDim2.new(1, -55, 0, 3)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(default)
        valLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
        valLabel.Font = Enum.Font.GothamBold
        valLabel.TextSize = 10
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent = frame
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Size = UDim2.new(1, -20, 0, 4)
        sliderBar.Position = UDim2.new(0, 10, 0, 28)
        sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        sliderBar.BorderSizePixel = 0
        sliderBar.Parent = frame
        
        local barCorner = Instance.new("UICorner"); barCorner.CornerRadius = UDim.new(0, 2); barCorner.Parent = sliderBar
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        fill.BorderSizePixel = 0
        fill.Parent = sliderBar
        
        local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(0, 2); fillCorner.Parent = fill
        
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end
    
    local function addButton(parent, name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 450, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.AutoButtonColor = false
        btn.Parent = parent
        
        local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 5); corner.Parent = btn
        local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(0, 200, 255); stroke.Thickness = 0.8; stroke.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            callback()
            btn.BackgroundColor3 = Color3.fromRGB(0, 140, 210)
            task.wait(0.1)
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        end)
    end
    
    local function addLabel(parent, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 450, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(0, 180, 255)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.Parent = parent
    end
    
    local function addInfoLabel(parent, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 450, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(160, 160, 160)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 9
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
    end
    
    -- Movement Tab
    addLabel(MovementPage, "--- MOVEMENT ---")
    addToggle(MovementPage, "Flight", false, function(state) Settings.Flight.Enabled = state; setupFlight() end)
    addSlider(MovementPage, "Flight Speed", 20, 300, 50, function(v) Settings.Flight.Speed = v end)
    addToggle(MovementPage, "Speed Boost", false, function(state) Settings.Speed.Enabled = state; setupSpeed() end)
    addSlider(MovementPage, "Walk Speed", 16, 300, 32, function(v) Settings.Speed.Value = v; if Settings.Speed.Enabled then setupSpeed() end end)
    addToggle(MovementPage, "Super Jump", false, function(state) Settings.Jump.Enabled = state; setupJump() end)
    addSlider(MovementPage, "Jump Power", 50, 1000, 100, function(v) Settings.Jump.Value = v; if Settings.Jump.Enabled then setupJump() end end)
    addToggle(MovementPage, "Infinite Jump", false, function(state) Settings.InfiniteJump.Enabled = state end)
    addToggle(MovementPage, "NoClip", false, function(state) Settings.NoClip.Enabled = state; setupNoClip() end)
    addToggle(MovementPage, "Click TP (Ctrl+Click)", false, function(state) Settings.ClickTP.Enabled = state end)
    
    -- Blocks Tab
    addLabel(BlocksPage, "--- BLOCK SPAWNER ---")
    addInfoLabel(BlocksPage, "NumPad1: Spawn | NumPad2: Clear | NumPad3: Teleport")
    addButton(BlocksPage, "Spawn Block Under You", function() spawnBlockUnder() end)
    addButton(BlocksPage, "Clear All Blocks", function() clearBlocks() end)
    addSlider(BlocksPage, "Block Size", 2, 50, 10, function(v) Settings.BlockSpawn.Size = v end)
    
    addLabel(BlocksPage, "--- COLORS ---")
    local colorGrid = Instance.new("Frame")
    colorGrid.Size = UDim2.new(0, 450, 0, 36)
    colorGrid.BackgroundTransparency = 1
    colorGrid.Parent = BlocksPage
    
    local cgLayout = Instance.new("UIGridLayout")
    cgLayout.CellSize = UDim2.new(0, 30, 0, 30)
    cgLayout.CellPadding = UDim2.new(0, 3, 0, 3)
    cgLayout.FillDirection = Enum.FillDirection.Horizontal
    cgLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cgLayout.Parent = colorGrid
    
    local colors = {
        {Color3.fromRGB(255,255,255), "White"}, {Color3.fromRGB(255,0,0), "Red"},
        {Color3.fromRGB(0,0,255), "Blue"}, {Color3.fromRGB(0,255,0), "Green"},
        {Color3.fromRGB(255,255,0), "Yellow"}, {Color3.fromRGB(255,0,255), "Pink"},
        {Color3.fromRGB(0,255,255), "Cyan"}, {Color3.fromRGB(128,0,128), "Purple"},
        {Color3.fromRGB(255,128,0), "Orange"}, {Color3.fromRGB(0,0,0), "Black"},
        {Color3.fromRGB(128,128,128), "Gray"}, {Color3.fromRGB(139,69,19), "Brown"}
    }
    
    for _, c in ipairs(colors) do
        local cb = Instance.new("TextButton")
        cb.Size = UDim2.new(0, 30, 0, 30)
        cb.BackgroundColor3 = c[1]
        cb.Text = ""
        cb.AutoButtonColor = false
        cb.Parent = colorGrid
        
        local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 3); cc.Parent = cb
        local cs = Instance.new("UIStroke"); cs.Color = Color3.fromRGB(255,255,255); cs.Thickness = 0.5; cs.Parent = cb
        
        cb.MouseButton1Click:Connect(function() Settings.BlockSpawn.Color = c[1]; notify("Color", c[2], 1.5) end)
    end
    
    addLabel(BlocksPage, "--- MATERIALS ---")
    local matGrid = Instance.new("Frame")
    matGrid.Size = UDim2.new(0, 450, 0, 65)
    matGrid.BackgroundTransparency = 1
    matGrid.Parent = BlocksPage
    
    local mgLayout = Instance.new("UIGridLayout")
    mgLayout.CellSize = UDim2.new(0, 68, 0, 26)
    mgLayout.CellPadding = UDim2.new(0, 3, 0, 3)
    mgLayout.FillDirection = Enum.FillDirection.Horizontal
    mgLayout.SortOrder = Enum.SortOrder.LayoutOrder
    mgLayout.Parent = matGrid
    
    local materials = {
        {"SmoothPlastic","Plastic"}, {"Wood","Wood"}, {"Brick","Brick"},
        {"Concrete","Concrete"}, {"Metal","Metal"}, {"Glass","Glass"},
        {"Ice","Ice"}, {"Neon","Neon"}, {"Marble","Marble"},
        {"Granite","Granite"}, {"Fabric","Fabric"}, {"Sand","Sand"}
    }
    
    for _, m in ipairs(materials) do
        local mb = Instance.new("TextButton")
        mb.Size = UDim2.new(0, 68, 0, 26)
        mb.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        mb.BackgroundTransparency = 0.05
        mb.Text = m[2]
        mb.TextColor3 = Color3.fromRGB(220, 220, 220)
        mb.Font = Enum.Font.Gotham
        mb.TextSize = 9
        mb.AutoButtonColor = false
        mb.Parent = matGrid
        
        local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 3); mc.Parent = mb
        local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(0, 140, 200); ms.Thickness = 0.5; ms.Parent = mb
        
        mb.MouseButton1Click:Connect(function() Settings.BlockSpawn.Material = m[1]; notify("Material", m[2], 1.5) end)
    end
    
    -- Visual Tab
    addLabel(VisualPage, "--- VISUAL ---")
    addToggle(VisualPage, "Player ESP", false, function(s) Settings.ESP.Enabled = s; setupESP() end)
    addToggle(VisualPage, "ESP Boxes", true, function(s) Settings.ESP.Boxes = s; setupESP() end)
    addToggle(VisualPage, "ESP Names", true, function(s) Settings.ESP.Names = s; setupESP() end)
    addToggle(VisualPage, "ESP Distance", true, function(s) Settings.ESP.Distance = s; setupESP() end)
    addToggle(VisualPage, "ESP Health", true, function(s) Settings.ESP.Health = s; setupESP() end)
    addToggle(VisualPage, "ESP Glow", false, function(s) Settings.ESP.Glow = s; setupESP() end)
    addToggle(VisualPage, "ESP Show Weapon", false, function(s) Settings.ESP.ShowWeapon = s; setupESP() end)
    addToggle(VisualPage, "ESP Team Check", false, function(s) Settings.ESP.TeamCheck = s; setupESP() end)
    addToggle(VisualPage, "ESP Team Color", false, function(s) Settings.ESP.TeamColor = s; setupESP() end)
    addToggle(VisualPage, "ESP Rainbow", false, function(s) Settings.ESP.Rainbow = s; setupESP() end)
    addToggle(VisualPage, "ESP Visible Only", false, function(s) Settings.ESP.VisibleOnly = s; setupESP() end)
    addToggle(VisualPage, "ESP Text Outline", true, function(s) Settings.ESP.TextOutline = s; setupESP() end)
    addSlider(VisualPage, "ESP Max Distance", 100, 5000, 500, function(v) Settings.ESP.MaxDistance = v end)
    
    addToggle(VisualPage, "Full Bright", false, function(s) Settings.FullBright.Enabled = s; setupFullBright() end)
    addSlider(VisualPage, "Field of View", 30, 120, 70, function(v) Settings.FOV = v; Camera.FieldOfView = v end)
    addToggle(VisualPage, "No Fog", false, function(s) Settings.NoFog.Enabled = s; Lighting.FogEnd = s and 9e9 or 500 end)
    addToggle(VisualPage, "Chams", false, function(s) Settings.Chams.Enabled = s; setupChams() end)
    addToggle(VisualPage, "X-Ray", false, function(s) Settings.XRay.Enabled = s; setupXRay() end)
    
    -- Combat Tab
    addLabel(CombatPage, "--- COMBAT ---")
    addToggle(CombatPage, "Aimbot", false, function(s) Settings.Aimbot.Enabled = s; setupAimbot() end)
    addSlider(CombatPage, "Aimbot FOV", 10, 360, 100, function(v) Settings.Aimbot.FOV = v end)
    addSlider(CombatPage, "Smoothness", 0.1, 1, 0.5, function(v) Settings.Aimbot.Smoothness = v end)
    addToggle(CombatPage, "Trigger Bot", false, function(s) Settings.TriggerBot.Enabled = s; setupTriggerBot() end)
    addToggle(CombatPage, "Silent Aim", false, function(s) Settings.SilentAim.Enabled = s end)
    addToggle(CombatPage, "Kill Aura", false, function(s) Settings.KillAura.Enabled = s; setupKillAura() end)
    addSlider(CombatPage, "Kill Aura Range", 5, 50, 20, function(v) Settings.KillAura.Range = v end)
    
    -- World Tab
    addLabel(WorldPage, "--- WORLD ---")
    addButton(WorldPage, "Teleport to Cursor", function() teleportToCursor(); notify("TP", "Done!", 1.5) end)
    addButton(WorldPage, "FPS Booster", function() boostFPS(); notify("FPS", "Boosted!", 2) end)
    addToggle(WorldPage, "Anti-AFK", false, function(s) Settings.AntiAfk.Enabled = s; setupAntiAfk() end)
    addToggle(WorldPage, "Time Changer", false, function(s) Settings.TimeChanger.Enabled = s end)
    addSlider(WorldPage, "Time", 0, 24, 14, function(v) if Settings.TimeChanger.Enabled then Lighting.ClockTime = v end end)
    addToggle(WorldPage, "Gravity Changer", false, function(s) Settings.Gravity.Enabled = s; Workspace.Gravity = s and Settings.Gravity.Value or 196.2 end)
    addSlider(WorldPage, "Gravity", 0, 500, 196.2, function(v) Settings.Gravity.Value = v; if Settings.Gravity.Enabled then Workspace.Gravity = v end end)
    
    -- Hub Chat Tab
    addLabel(ChatPage, "--- HUB CHAT ---")
    addInfoLabel(ChatPage, "Chat between Pro Hub users only")
    
    local chatDisplay = Instance.new("Frame")
    chatDisplay.Size = UDim2.new(0, 450, 0, 160)
    chatDisplay.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    chatDisplay.BackgroundTransparency = 0.05
    chatDisplay.BorderSizePixel = 0
    chatDisplay.Parent = ChatPage
    
    local cdCorner = Instance.new("UICorner"); cdCorner.CornerRadius = UDim.new(0, 5); cdCorner.Parent = chatDisplay
    local cdStroke = Instance.new("UIStroke"); cdStroke.Color = Color3.fromRGB(0, 140, 200); cdStroke.Thickness = 0.7; cdStroke.Parent = chatDisplay
    
    local chatScroller = Instance.new("ScrollingFrame")
    chatScroller.Size = UDim2.new(1, -8, 1, -8)
    chatScroller.Position = UDim2.new(0, 4, 0, 4)
    chatScroller.BackgroundTransparency = 1
    chatScroller.ScrollBarThickness = 2
    chatScroller.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
    chatScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatScroller.Parent = chatDisplay
    
    local chatLayout = Instance.new("UIListLayout"); chatLayout.Padding = UDim.new(0, 2); chatLayout.SortOrder = Enum.SortOrder.LayoutOrder; chatLayout.Parent = chatScroller
    
    local function updateChatDisplay()
        for _, child in pairs(chatScroller:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        
        local startIndex = math.max(1, #CustomChatMessages - 20)
        for i = startIndex, #CustomChatMessages do
            local msg = CustomChatMessages[i]
            local msgLabel = Instance.new("TextLabel")
            msgLabel.Size = UDim2.new(1, -4, 0, 18)
            msgLabel.BackgroundTransparency = 1
            msgLabel.Text = "[" .. msg.Name .. "]: " .. msg.Message
            msgLabel.TextColor3 = msg.UserId == LocalPlayer.UserId and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(200, 200, 200)
            msgLabel.Font = Enum.Font.Gotham
            msgLabel.TextSize = 10
            msgLabel.TextXAlignment = Enum.TextXAlignment.Left
            msgLabel.Parent = chatScroller
        end
        
        chatScroller.CanvasSize = UDim2.new(0, 0, 0, math.max(160, #CustomChatMessages * 20))
        chatScroller.CanvasPosition = Vector2.new(0, chatScroller.CanvasSize.Y.Offset)
    end
    
    local chatInputFrame = Instance.new("Frame")
    chatInputFrame.Size = UDim2.new(0, 450, 0, 36)
    chatInputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    chatInputFrame.BackgroundTransparency = 0.05
    chatInputFrame.BorderSizePixel = 0
    chatInputFrame.Parent = ChatPage
    
    local ciCorner = Instance.new("UICorner"); ciCorner.CornerRadius = UDim.new(0, 5); ciCorner.Parent = chatInputFrame
    local ciStroke = Instance.new("UIStroke"); ciStroke.Color = Color3.fromRGB(0, 140, 200); ciStroke.Thickness = 0.7; ciStroke.Parent = chatInputFrame
    
    local chatTextBox = Instance.new("TextBox")
    chatTextBox.Size = UDim2.new(1, -70, 1, 0)
    chatTextBox.Position = UDim2.new(0, 8, 0, 0)
    chatTextBox.BackgroundTransparency = 1
    chatTextBox.PlaceholderText = "Type message..."
    chatTextBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
    chatTextBox.Text = ""
    chatTextBox.TextColor3 = Color3.fromRGB(230, 230, 230)
    chatTextBox.Font = Enum.Font.Gotham
    chatTextBox.TextSize = 11
    chatTextBox.TextXAlignment = Enum.TextXAlignment.Left
    chatTextBox.ClearTextOnFocus = false
    chatTextBox.Parent = chatInputFrame
    
    local chatSendBtn = Instance.new("TextButton")
    chatSendBtn.Size = UDim2.new(0, 55, 0, 24)
    chatSendBtn.Position = UDim2.new(1, -62, 0.5, -12)
    chatSendBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    chatSendBtn.Text = "Send"
    chatSendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    chatSendBtn.Font = Enum.Font.GothamBold
    chatSendBtn.TextSize = 11
    chatSendBtn.AutoButtonColor = false
    chatSendBtn.Parent = chatInputFrame
    
    local csbCorner = Instance.new("UICorner"); csbCorner.CornerRadius = UDim.new(0, 4); csbCorner.Parent = chatSendBtn
    
    local function sendHubMessage()
        local msg = chatTextBox.Text
        if msg ~= "" then
            sendCustomChatMessage(msg)
            chatTextBox.Text = ""
            updateChatDisplay()
        end
    end
    
    chatSendBtn.MouseButton1Click:Connect(function()
        sendHubMessage()
        chatSendBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 210)
        task.wait(0.1)
        chatSendBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    end)
    
    chatTextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then sendHubMessage() end
    end)
    
    spawn(function() while true do updateChatDisplay(); task.wait(1) end end)
    
    -- Settings Tab
    addLabel(SettingsPage, "--- GAME INFO ---")
    
    local gameInfoFrame = Instance.new("Frame")
    gameInfoFrame.Size = UDim2.new(0, 450, 0, 65)
    gameInfoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    gameInfoFrame.BackgroundTransparency = 0.05
    gameInfoFrame.BorderSizePixel = 0
    gameInfoFrame.Parent = SettingsPage
    
    local giCorner = Instance.new("UICorner"); giCorner.CornerRadius = UDim.new(0, 5); giCorner.Parent = gameInfoFrame
    local giStroke = Instance.new("UIStroke"); giStroke.Color = Color3.fromRGB(0, 140, 200); giStroke.Thickness = 0.7; giStroke.Parent = gameInfoFrame
    
    local gnLabel = Instance.new("TextLabel")
    gnLabel.Size = UDim2.new(1, -20, 0, 18)
    gnLabel.Position = UDim2.new(0, 10, 0, 6)
    gnLabel.BackgroundTransparency = 1
    gnLabel.Text = "Game: Loading..."
    gnLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    gnLabel.Font = Enum.Font.GothamBold
    gnLabel.TextSize = 11
    gnLabel.TextXAlignment = Enum.TextXAlignment.Left
    gnLabel.Parent = gameInfoFrame
    
    local giLabel = Instance.new("TextLabel")
    giLabel.Size = UDim2.new(1, -20, 0, 16)
    giLabel.Position = UDim2.new(0, 10, 0, 26)
    giLabel.BackgroundTransparency = 1
    giLabel.Text = "ID: " .. game.PlaceId
    giLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    giLabel.Font = Enum.Font.Gotham
    giLabel.TextSize = 10
    giLabel.TextXAlignment = Enum.TextXAlignment.Left
    giLabel.Parent = gameInfoFrame
    
    local gwLabel = Instance.new("TextLabel")
    gwLabel.Size = UDim2.new(1, -20, 0, 16)
    gwLabel.Position = UDim2.new(0, 10, 0, 42)
    gwLabel.BackgroundTransparency = 1
    gwLabel.Text = "World: " .. game.JobId
    gwLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    gwLabel.Font = Enum.Font.Gotham
    gwLabel.TextSize = 10
    gwLabel.TextXAlignment = Enum.TextXAlignment.Left
    gwLabel.Parent = gameInfoFrame
    
    spawn(function()
        pcall(function()
            local info = MarketplaceService:GetProductInfo(game.PlaceId)
            gnLabel.Text = "Game: " .. (info.Name or "Unknown")
        end)
    end)
    
    addLabel(SettingsPage, "--- PLAYER ---")
    
    local playerFrame = Instance.new("Frame")
    playerFrame.Size = UDim2.new(0, 450, 0, 70)
    playerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    playerFrame.BackgroundTransparency = 0.05
    playerFrame.BorderSizePixel = 0
    playerFrame.Parent = SettingsPage
    
    local pfCorner = Instance.new("UICorner"); pfCorner.CornerRadius = UDim.new(0, 5); pfCorner.Parent = playerFrame
    local pfStroke = Instance.new("UIStroke"); pfStroke.Color = Color3.fromRGB(0, 140, 200); pfStroke.Thickness = 0.7; pfStroke.Parent = playerFrame
    
    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 55, 0, 55)
    avatar.Position = UDim2.new(0, 8, 0.5, -27)
    avatar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    avatar.Parent = playerFrame
    
    local avCorner = Instance.new("UICorner"); avCorner.CornerRadius = UDim.new(1, 0); avCorner.Parent = avatar
    local avStroke = Instance.new("UIStroke"); avStroke.Color = Color3.fromRGB(0, 180, 255); avStroke.Thickness = 0.8; avStroke.Parent = avatar
    
    spawn(function()
        pcall(function()
            local content = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            avatar.Image = content
        end)
    end)
    
    local pnLabel = Instance.new("TextLabel")
    pnLabel.Size = UDim2.new(1, -75, 0, 20)
    pnLabel.Position = UDim2.new(0, 70, 0, 10)
    pnLabel.BackgroundTransparency = 1
    pnLabel.Text = LocalPlayer.Name
    pnLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    pnLabel.Font = Enum.Font.GothamBold
    pnLabel.TextSize = 12
    pnLabel.TextXAlignment = Enum.TextXAlignment.Left
    pnLabel.Parent = playerFrame
    
    local paLabel = Instance.new("TextLabel")
    paLabel.Size = UDim2.new(1, -75, 0, 18)
    paLabel.Position = UDim2.new(0, 70, 0, 30)
    paLabel.BackgroundTransparency = 1
    paLabel.Text = "@" .. LocalPlayer.Name
    paLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
    paLabel.Font = Enum.Font.Gotham
    paLabel.TextSize = 10
    paLabel.TextXAlignment = Enum.TextXAlignment.Left
    paLabel.Parent = playerFrame
    
    local piLabel = Instance.new("TextLabel")
    piLabel.Size = UDim2.new(1, -75, 0, 16)
    piLabel.Position = UDim2.new(0, 70, 0, 48)
    piLabel.BackgroundTransparency = 1
    piLabel.Text = "ID: " .. LocalPlayer.UserId
    piLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    piLabel.Font = Enum.Font.Gotham
    piLabel.TextSize = 9
    piLabel.TextXAlignment = Enum.TextXAlignment.Left
    piLabel.Parent = playerFrame
    
    addLabel(SettingsPage, "--- ACTIONS ---")
    addButton(SettingsPage, "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    addButton(SettingsPage, "Copy Game Link", function() setclipboard("https://www.roblox.com/games/" .. game.PlaceId .. "/"); notify("Link", "Copied!", 1.5) end)
    
    -- Info Tab
    addLabel(InstructPage, "--- CREATOR ---")
    
    local creatorFrame = Instance.new("Frame")
    creatorFrame.Size = UDim2.new(0, 450, 0, 45)
    creatorFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    creatorFrame.BackgroundTransparency = 0.05
    creatorFrame.BorderSizePixel = 0
    creatorFrame.Parent = InstructPage
    
    local crCorner = Instance.new("UICorner"); crCorner.CornerRadius = UDim.new(0, 5); crCorner.Parent = creatorFrame
    local crStroke = Instance.new("UIStroke"); crStroke.Color = Color3.fromRGB(0, 140, 200); crStroke.Thickness = 0.7; crStroke.Parent = creatorFrame
    
    local crLabel = Instance.new("TextLabel")
    crLabel.Size = UDim2.new(1, 0, 1, 0)
    crLabel.BackgroundTransparency = 1
    crLabel.Text = "Created by: mcherenkovYT\nVersion: v1.2.1"
    crLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    crLabel.Font = Enum.Font.GothamBold
    crLabel.TextSize = 11
    crLabel.Parent = creatorFrame
    
    addLabel(InstructPage, "--- KEYBINDS ---")
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(0, 450, 0, 50)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = "NumPad1 - Block | NumPad2 - Clear\nNumPad3 - Teleport | RightShift - Hide GUI"
    keyLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
    keyLabel.Font = Enum.Font.Gotham
    keyLabel.TextSize = 10
    keyLabel.TextXAlignment = Enum.TextXAlignment.Left
    keyLabel.Parent = InstructPage
    
    -- Drag
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    return ScreenGui
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.KeypadOne then spawnBlockUnder()
    elseif input.KeyCode == Enum.KeyCode.KeypadTwo then clearBlocks()
    elseif input.KeyCode == Enum.KeyCode.KeypadThree then teleportToCursor(); notify("TP", "Done!", 1)
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        local gui = game:GetService("CoreGui"):FindFirstChild("ProCheatHub")
        if gui then gui.Enabled = not gui.Enabled end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump.Enabled then
        local hum = getHum()
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Click TP
Mouse.Button1Down:Connect(function()
    if Settings.ClickTP.Enabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then teleportToCursor() end
end)

-- Character Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Settings.Speed.Enabled then setupSpeed() end
    if Settings.Jump.Enabled then setupJump() end
    if Settings.Flight.Enabled then setupFlight() end
    if Settings.NoClip.Enabled then setupNoClip() end
end)

-- Initialize
createGUI()
notify("Pro Hub v1.2.1", "by mcherenkovYT | RightShift: Toggle", 6)
