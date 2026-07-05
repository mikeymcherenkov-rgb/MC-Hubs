--[[
    PRO CHEAT HUB v3.2 PREMIUM
    by mcherenkovYT
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
local TextChatService = game:GetService("TextChatService")
local MarketplaceService = game:GetService("MarketplaceService")

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
    
    -- Block Spawn
    BlockSpawn = {Enabled = false, Size = 10, Material = "SmoothPlastic", Color = Color3.fromRGB(255, 255, 255)},
    
    -- Visual
    ESP = {Enabled = false, Boxes = true, Tracers = true, Names = true, Distance = true, Health = true},
    FullBright = {Enabled = false},
    FOV = 70,
    NoFog = {Enabled = false},
    Chams = {Enabled = false},
    XRay = {Enabled = false},
    
    -- Combat
    Aimbot = {Enabled = false, FOV = 100, Smoothness = 0.5, TargetPart = "Head", TeamCheck = false, VisibilityCheck = true},
    TriggerBot = {Enabled = false, Delay = 0.1},
    SilentAim = {Enabled = false, FOV = 50},
    KillAura = {Enabled = false, Range = 20},
    
    -- World
    AntiAfk = {Enabled = false},
    TimeChanger = {Enabled = false, Time = 14},
    Gravity = {Enabled = false, Value = 196.2},
    
    -- Misc
    StreamSnipe = {Enabled = false},
    AutoReconnect = {Enabled = false},
    ChatSpy = {Enabled = false},
    SilentChat = {Enabled = false}
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

local function notify(title, text, dur)
    spawn(function()
        local sg = Instance.new("ScreenGui")
        sg.Parent = game:GetService("CoreGui")
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 300, 0, 70)
        f.Position = UDim2.new(1, 0, 0.7, 0)
        f.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
        f.BackgroundTransparency = 0.15
        f.BorderSizePixel = 0
        f.Parent = sg
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = f
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 170, 255)
        stroke.Thickness = 1.5
        stroke.Parent = f
        
        local glow = Instance.new("ImageLabel")
        glow.Size = UDim2.new(1, 20, 1, 20)
        glow.Position = UDim2.new(0, -10, 0, -10)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://6014261993"
        glow.ImageColor3 = Color3.fromRGB(0, 170, 255)
        glow.ImageTransparency = 0.85
        glow.Parent = f
        
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

-- ============ ПОЛЁТ ============
local function setupFlight()
    local char = getChar()
    if not char then return end
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end
    
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
        if not root or not hum or hum.Health <= 0 then 
            setupFlight()
            return 
        end
        
        local moveVector = Vector3.zero
        local cameraForward = Camera.CFrame.LookVector
        local cameraRight = Camera.CFrame.RightVector
        
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
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector += Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector -= Vector3.new(0, 1, 0)
        end
        
        local speedMultiplier = 1
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            speedMultiplier = 2.5
        end
        
        if moveVector.Magnitude > 0 then
            bodyVelocity.Velocity = moveVector.Unit * Settings.Flight.Speed * speedMultiplier
        else
            bodyVelocity.Velocity = Vector3.zero
        end
        
        bodyGyro.CFrame = CFrame.new(root.Position, root.Position + Camera.CFrame.LookVector)
    end)
end

-- ============ БЛОК ПОД СОБОЙ ============
local function spawnBlockUnder()
    local root = getRoot()
    if not root then return end
    
    local spawnPos = root.Position - Vector3.new(0, 5, 0)
    
    if #SpawnedBlocks > 50 then
        for i = 1, 10 do
            local oldBlock = table.remove(SpawnedBlocks, 1)
            if oldBlock then oldBlock:Destroy() end
        end
    end
    
    local block = Instance.new("Part")
    block.Name = "SpawnedBlock_" .. os.time()
    block.Size = Vector3.new(Settings.BlockSpawn.Size, 2, Settings.BlockSpawn.Size)
    block.Position = spawnPos
    block.Anchored = true
    block.CanCollide = true
    block.Material = Enum.Material[Settings.BlockSpawn.Material]
    block.Color = Settings.BlockSpawn.Color
    block.Parent = Workspace
    
    table.insert(SpawnedBlocks, block)
    notify("Block Spawned", "Block created! Total: " .. #SpawnedBlocks, 2)
    
    return block
end

local function clearBlocks()
    for _, block in pairs(SpawnedBlocks) do
        if block then block:Destroy() end
    end
    SpawnedBlocks = {}
    notify("Blocks Cleared", "All blocks removed!", 2)
end

-- // Movement functions
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

-- // Combat functions
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
        if hit:IsDescendantOf(target.Character) then return true end
    end
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
        
        local targetPart = target.Character and target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
        if not targetPart then return end
        
        local lookAt = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, Settings.Aimbot.Smoothness)
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
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local hum = player.Character:FindFirstChildOfClass("Humanoid")
                        local myRoot = getRoot()
                        local theirRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if hum and myRoot and theirRoot then
                            if (myRoot.Position - theirRoot.Position).Magnitude <= Settings.KillAura.Range then
                                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                                    if remote:IsA("RemoteEvent") then
                                        pcall(function() remote:FireServer(player, hum, 100) end)
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

-- // Visual functions
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
                        healthFill.BackgroundColor3 = health < hum.MaxHealth * 0.3 and Color3.fromRGB(255, 0, 0) or health < hum.MaxHealth * 0.6 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(0, 255, 0)
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
        
        if player.Character then onChar(player.Character) end
        player.CharacterAdded:Connect(onChar)
    end
    
    for _, p in pairs(Players:GetPlayers()) do addESP(p) end
    Players.PlayerAdded:Connect(addESP)
end

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
            if obj:IsA("BasePart") then obj.LocalTransparencyModifier = 0 end
        end
    end
end

-- // World functions
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

-- // Chat functions
local function sendChatMessage(message)
    if not message or message == "" then return end
    
    local success = pcall(function()
        if TextChatService.ChatInputBarConfiguration then
            local textChannels = TextChatService:FindFirstChild("TextChannels")
            if textChannels then
                local generalChannel = textChannels:FindFirstChild("RBXGeneral")
                if generalChannel then
                    generalChannel:SendAsync(message)
                    return true
                end
            end
        end
    end)
    if success then notify("Chat", "Sent: " .. message, 2); return end
    
    local success2 = pcall(function()
        local chatService = game:GetService("Chat")
        if chatService then
            chatService:Chat(LocalPlayer.Character.Head, message, Enum.ChatColor.Blue)
            return true
        end
    end)
    if success2 then notify("Chat", "Sent: " .. message, 2); return end
    
    local success3 = pcall(function()
        local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatRemote then
            local sayMessageRequest = chatRemote:FindFirstChild("SayMessageRequest")
            if sayMessageRequest then
                sayMessageRequest:FireServer(message, "All")
                return true
            end
        end
    end)
    if success3 then notify("Chat", "Sent: " .. message, 2); return end
    
    notify("Chat Error", "Could not send!", 3)
end

local function openChatGUI()
    local chatGui = game:GetService("CoreGui"):FindFirstChild("CustomChatInput")
    if chatGui then chatGui:Destroy(); return end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "CustomChatInput"
    sg.Parent = game:GetService("CoreGui")
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 42)
    frame.Position = UDim2.new(0.5, -175, 0.85, 0)
    frame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = sg
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 170, 255)
    stroke.Thickness = 1.5
    stroke.Parent = frame
    
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://6014261993"
    glow.ImageColor3 = Color3.fromRGB(0, 170, 255)
    glow.ImageTransparency = 0.85
    glow.Parent = frame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -60, 1, 0)
    textBox.Position = UDim2.new(0, 10, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.PlaceholderText = "Type message..."
    textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    textBox.Text = ""
    textBox.TextColor3 = Color3.new(1, 1, 1)
    textBox.Font = Enum.Font.SourceSans
    textBox.TextSize = 14
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = false
    textBox.Parent = frame
    
    local sendBtn = Instance.new("TextButton")
    sendBtn.Size = UDim2.new(0, 50, 0, 26)
    sendBtn.Position = UDim2.new(1, -56, 0.5, -13)
    sendBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    sendBtn.Text = "Send"
    sendBtn.TextColor3 = Color3.new(1, 1, 1)
    sendBtn.Font = Enum.Font.SourceSansBold
    sendBtn.TextSize = 12
    sendBtn.AutoButtonColor = false
    sendBtn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = sendBtn
    
    local function sendMessage()
        local msg = textBox.Text
        if msg ~= "" then sendChatMessage(msg); textBox.Text = "" end
    end
    
    sendBtn.MouseButton1Click:Connect(function()
        sendMessage()
        sendBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
        task.wait(0.1)
        sendBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end)
    
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then sendMessage() end
    end)
    
    textBox:CaptureFocus()
    notify("Chat", "Opened! Type and press Enter or Send.", 3)
end

local function teleportToCursor()
    local root = getRoot()
    if not root then return end
    
    local target = Mouse.Hit
    local rayResult = raycast(target.Position + Vector3.new(0, 20, 0), target.Position + Vector3.new(0, -40, 0))
    local finalPos = target.Position + Vector3.new(0, 3, 0)
    if rayResult then finalPos = rayResult.Position + Vector3.new(0, 3, 0) end
    
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
    
    -- Main Frame (полупрозрачный)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 650, 0, 440)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -220)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(0, 170, 255)
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame
    
    -- Glow effect
    local MainGlow = Instance.new("ImageLabel")
    MainGlow.Size = UDim2.new(1, 24, 1, 24)
    MainGlow.Position = UDim2.new(0, -12, 0, -12)
    MainGlow.BackgroundTransparency = 1
    MainGlow.Image = "rbxassetid://6014261993"
    MainGlow.ImageColor3 = Color3.fromRGB(0, 170, 255)
    MainGlow.ImageTransparency = 0.9
    MainGlow.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 36)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BackgroundTransparency = 0.1
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar
    
    local TitleGlow = Instance.new("ImageLabel")
    TitleGlow.Size = UDim2.new(1, 0, 1, 8)
    TitleGlow.Position = UDim2.new(0, 0, 1, -4)
    TitleGlow.BackgroundTransparency = 1
    TitleGlow.Image = "rbxassetid://6014261993"
    TitleGlow.ImageColor3 = Color3.fromRGB(0, 170, 255)
    TitleGlow.ImageTransparency = 0.85
    TitleGlow.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(0, 300, 1, 0)
    TitleText.Position = UDim2.new(0, 14, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "⚡ PRO CHEAT HUB v3.2"
    TitleText.TextColor3 = Color3.fromRGB(0, 170, 255)
    TitleText.Font = Enum.Font.SourceSansBold
    TitleText.TextSize = 14
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 26, 0, 26)
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 13
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Tab Buttons Container (с отступами)
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 130, 1, -36)
    TabContainer.Position = UDim2.new(0, 4, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 4)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer
    
    -- Content Pages Container
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -138, 1, -40)
    ContentFrame.Position = UDim2.new(0, 134, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    
    local pages = {}
    local tabButtons = {}
    
    local function switchTab(page, button)
        for _, p in pairs(pages) do p.Visible = false end
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
        tabBtn.Size = UDim2.new(1, 0, 0, 32)
        tabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        tabBtn.BackgroundTransparency = 0.15
        tabBtn.Text = "  " .. icon .. "  " .. name
        tabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
        tabBtn.Font = Enum.Font.SourceSans
        tabBtn.TextSize = 12
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.AutoButtonColor = false
        tabBtn.Parent = TabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabBtn
        
        local tabStroke = Instance.new("UIStroke")
        tabStroke.Color = Color3.fromRGB(0, 140, 200)
        tabStroke.Thickness = 0.8
        tabStroke.Parent = tabBtn
        
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
        layout.Padding = UDim.new(0, 5)
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
                    total = total + child.Size.Y.Offset + 5
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
    local MiscPage = createTab("Misc", "🔧")
    local SettingsPage = createTab("Settings", "⚙️")
    local InstructPage = createTab("Instructions", "📖")
    
    switchTab(pages[1], tabButtons[1])
    
    -- // UI Elements
    local function addToggle(parent, name, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 470, 0, 36)
        frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        frame.BackgroundTransparency = 0.15
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = frame
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 140, 200)
        stroke.Thickness = 0.8
        stroke.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 350, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 42, 0, 22)
        btn.Position = UDim2.new(1, -54, 0.5, -11)
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
        
        return {SetState = function(s) state = s; btn.BackgroundColor3 = s and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50) end}
    end
    
    local function addSlider(parent, name, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 470, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        frame.BackgroundTransparency = 0.15
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = frame
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 140, 200)
        stroke.Thickness = 0.8
        stroke.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 180, 0, 18)
        label.Position = UDim2.new(0, 12, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0, 50, 0, 18)
        valLabel.Position = UDim2.new(1, -60, 0, 4)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(default)
        valLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        valLabel.Font = Enum.Font.SourceSansBold
        valLabel.TextSize = 11
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent = frame
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Size = UDim2.new(1, -24, 0, 4)
        sliderBar.Position = UDim2.new(0, 12, 0, 30)
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
                dragging = true; update(input)
            end
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
        btn.Size = UDim2.new(0, 470, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        btn.BackgroundTransparency = 0.1
        btn.Text = name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 200, 255)
        stroke.Thickness = 1
        stroke.Parent = btn
        
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
        lbl.TextColor3 = Color3.fromRGB(0, 170, 255)
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.Parent = parent
    end
    
    local function addInfoLabel(parent, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 470, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
        lbl.Font = Enum.Font.SourceSans
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
    end
    
    -- ============ MOVEMENT TAB ============
    addLabel(MovementPage, "—— MOVEMENT ——")
    
    addToggle(MovementPage, "Flight", false, function(state)
        Settings.Flight.Enabled = state; setupFlight()
    end)
    addSlider(MovementPage, "Flight Speed", 20, 300, 50, function(value)
        Settings.Flight.Speed = value
    end)
    addToggle(MovementPage, "Speed Boost", false, function(state)
        Settings.Speed.Enabled = state; setupSpeed()
    end)
    addSlider(MovementPage, "Walk Speed", 16, 300, 32, function(value)
        Settings.Speed.Value = value; if Settings.Speed.Enabled then setupSpeed() end
    end)
    addToggle(MovementPage, "Super Jump", false, function(state)
        Settings.Jump.Enabled = state; setupJump()
    end)
    addSlider(MovementPage, "Jump Power", 50, 1000, 100, function(value)
        Settings.Jump.Value = value; if Settings.Jump.Enabled then setupJump() end
    end)
    addToggle(MovementPage, "Infinite Jump", false, function(state)
        Settings.InfiniteJump.Enabled = state
    end)
    addToggle(MovementPage, "NoClip", false, function(state)
        Settings.NoClip.Enabled = state; setupNoClip()
    end)
    addToggle(MovementPage, "Click TP (Ctrl+Click)", false, function(state)
        Settings.ClickTP.Enabled = state
    end)
    
    -- ============ BLOCKS TAB ============
    addLabel(BlocksPage, "—— BLOCK SPAWNER ——")
    addInfoLabel(BlocksPage, "NumPad1: Spawn | NumPad2: Clear | NumPad3: Teleport")
    
    addButton(BlocksPage, "Spawn Block Under You", function() spawnBlockUnder() end)
    addButton(BlocksPage, "Clear All Blocks", function() clearBlocks() end)
    addSlider(BlocksPage, "Block Size", 2, 50, 10, function(value)
        Settings.BlockSpawn.Size = value
    end)
    
    -- Grid with colors
    addLabel(BlocksPage, "—— COLORS ——")
    
    local colorGrid = Instance.new("Frame")
    colorGrid.Size = UDim2.new(0, 470, 0, 36)
    colorGrid.BackgroundTransparency = 1
    colorGrid.Parent = BlocksPage
    
    local colorGridLayout = Instance.new("UIGridLayout")
    colorGridLayout.CellSize = UDim2.new(0, 32, 0, 32)
    colorGridLayout.CellPadding = UDim2.new(0, 4, 0, 4)
    colorGridLayout.FillDirection = Enum.FillDirection.Horizontal
    colorGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    colorGridLayout.Parent = colorGrid
    
    local colors = {
        {Color3.fromRGB(255, 255, 255), "White"},
        {Color3.fromRGB(255, 0, 0), "Red"},
        {Color3.fromRGB(0, 0, 255), "Blue"},
        {Color3.fromRGB(0, 255, 0), "Green"},
        {Color3.fromRGB(255, 255, 0), "Yellow"},
        {Color3.fromRGB(255, 0, 255), "Pink"},
        {Color3.fromRGB(0, 255, 255), "Cyan"},
        {Color3.fromRGB(128, 0, 128), "Purple"},
        {Color3.fromRGB(255, 128, 0), "Orange"},
        {Color3.fromRGB(0, 0, 0), "Black"},
        {Color3.fromRGB(128, 128, 128), "Gray"},
        {Color3.fromRGB(139, 69, 19), "Brown"}
    }
    
    for _, c in ipairs(colors) do
        local colorBox = Instance.new("TextButton")
        colorBox.Size = UDim2.new(0, 32, 0, 32)
        colorBox.BackgroundColor3 = c[1]
        colorBox.Text = ""
        colorBox.AutoButtonColor = false
        colorBox.Parent = colorGrid
        
        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 4)
        cCorner.Parent = colorBox
        
        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(255, 255, 255)
        cStroke.Thickness = 0.5
        cStroke.Parent = colorBox
        
        colorBox.MouseButton1Click:Connect(function()
            Settings.BlockSpawn.Color = c[1]
            notify("Color", c[2], 1.5)
        end)
    end
    
    -- Grid with materials
    addLabel(BlocksPage, "—— MATERIALS ——")
    
    local materials = {
        {"SmoothPlastic", "Plastic"},
        {"Wood", "Wood"},
        {"Brick", "Brick"},
        {"Concrete", "Concrete"},
        {"Metal", "Metal"},
        {"Glass", "Glass"},
        {"Ice", "Ice"},
        {"Neon", "Neon"},
        {"Marble", "Marble"},
        {"Granite", "Granite"},
        {"Fabric", "Fabric"},
        {"Sand", "Sand"}
    }
    
    local matGrid = Instance.new("Frame")
    matGrid.Size = UDim2.new(0, 470, 0, 70)
    matGrid.BackgroundTransparency = 1
    matGrid.Parent = BlocksPage
    
    local matGridLayout = Instance.new("UIGridLayout")
    matGridLayout.CellSize = UDim2.new(0, 70, 0, 28)
    matGridLayout.CellPadding = UDim2.new(0, 4, 0, 4)
    matGridLayout.FillDirection = Enum.FillDirection.Horizontal
    matGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    matGridLayout.Parent = matGrid
    
    for _, m in ipairs(materials) do
        local matBox = Instance.new("TextButton")
        matBox.Size = UDim2.new(0, 70, 0, 28)
        matBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        matBox.BackgroundTransparency = 0.15
        matBox.Text = m[2]
        matBox.TextColor3 = Color3.new(1, 1, 1)
        matBox.Font = Enum.Font.SourceSans
        matBox.TextSize = 10
        matBox.AutoButtonColor = false
        matBox.Parent = matGrid
        
        local mCorner = Instance.new("UICorner")
        mCorner.CornerRadius = UDim.new(0, 4)
        mCorner.Parent = matBox
        
        local mStroke = Instance.new("UIStroke")
        mStroke.Color = Color3.fromRGB(0, 140, 200)
        mStroke.Thickness = 0.5
        mStroke.Parent = matBox
        
        matBox.MouseButton1Click:Connect(function()
            Settings.BlockSpawn.Material = m[1]
            notify("Material", m[2], 1.5)
        end)
    end
    
    -- ============ VISUAL TAB ============
    addLabel(VisualPage, "—— VISUAL ——")
    
    addToggle(VisualPage, "Player ESP", false, function(state)
        Settings.ESP.Enabled = state; setupESP()
    end)
    addToggle(VisualPage, "ESP Boxes", true, function(state)
        Settings.ESP.Boxes = state; setupESP()
    end)
    addToggle(VisualPage, "ESP Names", true, function(state)
        Settings.ESP.Names = state; setupESP()
    end)
    addToggle(VisualPage, "ESP Distance", true, function(state)
        Settings.ESP.Distance = state; setupESP()
    end)
    addToggle(VisualPage, "ESP Health", true, function(state)
        Settings.ESP.Health = state; setupESP()
    end)
    addToggle(VisualPage, "Full Bright", false, function(state)
        Settings.FullBright.Enabled = state; setupFullBright()
    end)
    addSlider(VisualPage, "Field of View", 30, 120, 70, function(value)
        Settings.FOV = value; Camera.FieldOfView = value
    end)
    addToggle(VisualPage, "No Fog", false, function(state)
        Settings.NoFog.Enabled = state
        Lighting.FogEnd = state and 9e9 or 500
        Lighting.FogStart = state and 9e9 or 0
    end)
    addToggle(VisualPage, "Chams", false, function(state)
        Settings.Chams.Enabled = state; setupChams()
    end)
    addToggle(VisualPage, "X-Ray", false, function(state)
        Settings.XRay.Enabled = state; setupXRay()
    end)
    
    -- ============ COMBAT TAB ============
    addLabel(CombatPage, "—— COMBAT ——")
    
    addToggle(CombatPage, "Aimbot", false, function(state)
        Settings.Aimbot.Enabled = state; setupAimbot()
    end)
    addSlider(CombatPage, "Aimbot FOV", 10, 360, 100, function(value)
        Settings.Aimbot.FOV = value
    end)
    addSlider(CombatPage, "Aimbot Smoothness", 0.1, 1, 0.5, function(value)
        Settings.Aimbot.Smoothness = value
    end)
    addToggle(CombatPage, "Trigger Bot", false, function(state)
        Settings.TriggerBot.Enabled = state; setupTriggerBot()
    end)
    addToggle(CombatPage, "Silent Aim", false, function(state)
        Settings.SilentAim.Enabled = state
    end)
    addToggle(CombatPage, "Kill Aura", false, function(state)
        Settings.KillAura.Enabled = state; setupKillAura()
    end)
    addSlider(CombatPage, "Kill Aura Range", 5, 50, 20, function(value)
        Settings.KillAura.Range = value
    end)
    
    -- ============ WORLD TAB ============
    addLabel(WorldPage, "—— WORLD ——")
    
    addButton(WorldPage, "Teleport to Cursor", function()
        teleportToCursor(); notify("Teleport", "Done!", 1.5)
    end)
    addButton(WorldPage, "FPS Booster", function()
        boostFPS(); notify("FPS", "Boosted!", 2)
    end)
    addToggle(WorldPage, "Anti-AFK", false, function(state)
        Settings.AntiAfk.Enabled = state; setupAntiAfk()
    end)
    addToggle(WorldPage, "Time Changer", false, function(state)
        Settings.TimeChanger.Enabled = state
    end)
    addSlider(WorldPage, "Time", 0, 24, 14, function(value)
        if Settings.TimeChanger.Enabled then Lighting.ClockTime = value end
    end)
    addToggle(WorldPage, "Gravity Changer", false, function(state)
        Settings.Gravity.Enabled = state
        Workspace.Gravity = state and Settings.Gravity.Value or 196.2
    end)
    addSlider(WorldPage, "Gravity", 0, 500, 196.2, function(value)
        Settings.Gravity.Value = value
        if Settings.Gravity.Enabled then Workspace.Gravity = value end
    end)
    
    -- ============ MISC TAB ============
    addLabel(MiscPage, "—— MISCELLANEOUS ——")
    
    addButton(MiscPage, "Open Chat", function() openChatGUI() end)
    addToggle(MiscPage, "Stream Snipe", false, function(state)
        Settings.StreamSnipe.Enabled = state
    end)
    addToggle(MiscPage, "Auto Reconnect", false, function(state)
        Settings.AutoReconnect.Enabled = state
    end)
    addToggle(MiscPage, "Chat Spy", false, function(state)
        Settings.ChatSpy.Enabled = state
    end)
    addToggle(MiscPage, "Silent Chat", false, function(state)
        Settings.SilentChat.Enabled = state
    end)
    
    -- ============ SETTINGS TAB ============
    addLabel(SettingsPage, "—— GAME INFO ——")
    
    -- Game info
    local gameInfoFrame = Instance.new("Frame")
    gameInfoFrame.Size = UDim2.new(0, 470, 0, 80)
    gameInfoFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    gameInfoFrame.BackgroundTransparency = 0.15
    gameInfoFrame.BorderSizePixel = 0
    gameInfoFrame.Parent = SettingsPage
    
    local giCorner = Instance.new("UICorner")
    giCorner.CornerRadius = UDim.new(0, 6)
    giCorner.Parent = gameInfoFrame
    
    local giStroke = Instance.new("UIStroke")
    giStroke.Color = Color3.fromRGB(0, 140, 200)
    giStroke.Thickness = 0.8
    giStroke.Parent = gameInfoFrame
    
    local gameNameLabel = Instance.new("TextLabel")
    gameNameLabel.Size = UDim2.new(1, -20, 0, 20)
    gameNameLabel.Position = UDim2.new(0, 10, 0, 6)
    gameNameLabel.BackgroundTransparency = 1
    gameNameLabel.Text = "🎮 Game: Loading..."
    gameNameLabel.TextColor3 = Color3.new(1, 1, 1)
    gameNameLabel.Font = Enum.Font.SourceSansBold
    gameNameLabel.TextSize = 12
    gameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    gameNameLabel.Parent = gameInfoFrame
    
    local gameIdLabel = Instance.new("TextLabel")
    gameIdLabel.Size = UDim2.new(1, -20, 0, 18)
    gameIdLabel.Position = UDim2.new(0, 10, 0, 28)
    gameIdLabel.BackgroundTransparency = 1
    gameIdLabel.Text = "🆔 ID: " .. game.PlaceId
    gameIdLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    gameIdLabel.Font = Enum.Font.SourceSans
    gameIdLabel.TextSize = 11
    gameIdLabel.TextXAlignment = Enum.TextXAlignment.Left
    gameIdLabel.Parent = gameInfoFrame
    
    local gameWorldLabel = Instance.new("TextLabel")
    gameWorldLabel.Size = UDim2.new(1, -20, 0, 18)
    gameWorldLabel.Position = UDim2.new(0, 10, 0, 46)
    gameWorldLabel.BackgroundTransparency = 1
    gameWorldLabel.Text = "🌍 World: " .. game.JobId
    gameWorldLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    gameWorldLabel.Font = Enum.Font.SourceSans
    gameWorldLabel.TextSize = 11
    gameWorldLabel.TextXAlignment = Enum.TextXAlignment.Left
    gameWorldLabel.Parent = gameInfoFrame
    
    spawn(function()
        pcall(function()
            local info = MarketplaceService:GetProductInfo(game.PlaceId)
            gameNameLabel.Text = "🎮 Game: " .. (info.Name or "Unknown")
        end)
    end)
    
    -- Player Info
    addLabel(SettingsPage, "—— PLAYER INFO ——")
    
    local playerInfoFrame = Instance.new("Frame")
    playerInfoFrame.Size = UDim2.new(0, 470, 0, 80)
    playerInfoFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    playerInfoFrame.BackgroundTransparency = 0.15
    playerInfoFrame.BorderSizePixel = 0
    playerInfoFrame.Parent = SettingsPage
    
    local piCorner = Instance.new("UICorner")
    piCorner.CornerRadius = UDim.new(0, 6)
    piCorner.Parent = playerInfoFrame
    
    local piStroke = Instance.new("UIStroke")
    piStroke.Color = Color3.fromRGB(0, 140, 200)
    piStroke.Thickness = 0.8
    piStroke.Parent = playerInfoFrame
    
    -- Avatar image
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(0, 60, 0, 60)
    avatarImage.Position = UDim2.new(0, 10, 0.5, -30)
    avatarImage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    avatarImage.Parent = playerInfoFrame
    
    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(1, 0)
    avCorner.Parent = avatarImage
    
    local avStroke = Instance.new("UIStroke")
    avStroke.Color = Color3.fromRGB(0, 170, 255)
    avStroke.Thickness = 1
    avStroke.Parent = avatarImage
    
    spawn(function()
        pcall(function()
            local userId = LocalPlayer.UserId
            local thumbType = Enum.ThumbnailType.HeadShot
            local thumbSize = Enum.ThumbnailSize.Size420x420
            local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
            avatarImage.Image = content
        end)
    end)
    
    local playerNameLabel = Instance.new("TextLabel")
    playerNameLabel.Size = UDim2.new(1, -80, 0, 22)
    playerNameLabel.Position = UDim2.new(0, 80, 0, 14)
    playerNameLabel.BackgroundTransparency = 1
    playerNameLabel.Text = "👤 " .. LocalPlayer.Name
    playerNameLabel.TextColor3 = Color3.new(1, 1, 1)
    playerNameLabel.Font = Enum.Font.SourceSansBold
    playerNameLabel.TextSize = 13
    playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerNameLabel.Parent = playerInfoFrame
    
    local playerAtLabel = Instance.new("TextLabel")
    playerAtLabel.Size = UDim2.new(1, -80, 0, 20)
    playerAtLabel.Position = UDim2.new(0, 80, 0, 38)
    playerAtLabel.BackgroundTransparency = 1
    playerAtLabel.Text = "@" .. LocalPlayer.Name
    playerAtLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    playerAtLabel.Font = Enum.Font.SourceSans
    playerAtLabel.TextSize = 11
    playerAtLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerAtLabel.Parent = playerInfoFrame
    
    local playerIdLabel = Instance.new("TextLabel")
    playerIdLabel.Size = UDim2.new(1, -80, 0, 18)
    playerIdLabel.Position = UDim2.new(0, 80, 0, 56)
    playerIdLabel.BackgroundTransparency = 1
    playerIdLabel.Text = "🆔 " .. LocalPlayer.UserId
    playerIdLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    playerIdLabel.Font = Enum.Font.SourceSans
    playerIdLabel.TextSize = 10
    playerIdLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerIdLabel.Parent = playerInfoFrame
    
    -- Action buttons
    addLabel(SettingsPage, "—— ACTIONS ——")
    addButton(SettingsPage, "Rejoin Server", function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    addButton(SettingsPage, "Server Hop", function()
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if success and result then
            for _, s in ipairs(result.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id); break
                end
            end
        end
        notify("Server Hop", "Searching...", 2)
    end)
    addButton(SettingsPage, "Copy Game Link", function()
        setclipboard("https://www.roblox.com/games/" .. game.PlaceId .. "/")
        notify("Link", "Copied!", 1.5)
    end)
    
    -- ============ INSTRUCTIONS TAB ============
    addLabel(InstructPage, "—— CREATOR ——")
    
    local creatorFrame = Instance.new("Frame")
    creatorFrame.Size = UDim2.new(0, 470, 0, 50)
    creatorFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    creatorFrame.BackgroundTransparency = 0.15
    creatorFrame.BorderSizePixel = 0
    creatorFrame.Parent = InstructPage
    
    local crCorner = Instance.new("UICorner")
    crCorner.CornerRadius = UDim.new(0, 6)
    crCorner.Parent = creatorFrame
    
    local crStroke = Instance.new("UIStroke")
    crStroke.Color = Color3.fromRGB(0, 140, 200)
    crStroke.Thickness = 0.8
    crStroke.Parent = creatorFrame
    
    local creatorLabel = Instance.new("TextLabel")
    creatorLabel.Size = UDim2.new(1, 0, 1, 0)
    creatorLabel.BackgroundTransparency = 1
    creatorLabel.Text = "Создатель чита: mcherenkovYT\nВерсия: v3.2 PREMIUM"
    creatorLabel.TextColor3 = Color3.new(1, 1, 1)
    creatorLabel.Font = Enum.Font.SourceSansBold
    creatorLabel.TextSize = 13
    creatorLabel.Parent = creatorFrame
    
    -- Movement Instructions
    addLabel(InstructPage, "—— MOVEMENT (Движение) ——")
    
    local moveInstr = Instance.new("TextLabel")
    moveInstr.Size = UDim2.new(0, 460, 0, 200)
    moveInstr.BackgroundTransparency = 1
    moveInstr.Text = [[
🛩️ Flight - Полёт. Используй WASD для движения, Space/Shift для подъёма/спуска, Ctrl для ускорения.

⚡ Speed Boost - Увеличивает скорость ходьбы. Настрой слайдером.

🦘 Super Jump - Супер-прыжок. Увеличивает высоту прыжка. Настрой слайдером.

♾️ Infinite Jump - Бесконечные прыжки. Можно прыгать даже в воздухе.

👻 NoClip - Прохождение сквозь стены. Включает отключение коллизий персонажа.

📍 Click TP - Телепорт по клику. Зажми Ctrl и кликни левой кнопкой мыши для телепорта.
]]
    moveInstr.TextColor3 = Color3.fromRGB(200, 200, 200)
    moveInstr.Font = Enum.Font.SourceSans
    moveInstr.TextSize = 11
    moveInstr.TextXAlignment = Enum.TextXAlignment.Left
    moveInstr.TextYAlignment = Enum.TextYAlignment.Top
    moveInstr.Parent = InstructPage
    
    -- Blocks Instructions
    addLabel(InstructPage, "—— BLOCKS (Блоки) ——")
    
    local blockInstr = Instance.new("TextLabel")
    blockInstr.Size = UDim2.new(0, 460, 0, 120)
    blockInstr.BackgroundTransparency = 1
    blockInstr.Text = [[
🧱 Block Spawner - Создаёт блок под вами.
   NumPad1 - Создать блок
   NumPad2 - Очистить все блоки
   NumPad3 - Телепорт к курсору

Выбери цвет из сетки цветов и материал из сетки материалов.
Блок создаётся прямо под персонажем с выбранными параметрами.
]]
    blockInstr.TextColor3 = Color3.fromRGB(200, 200, 200)
    blockInstr.Font = Enum.Font.SourceSans
    blockInstr.TextSize = 11
    blockInstr.TextXAlignment = Enum.TextXAlignment.Left
    blockInstr.TextYAlignment = Enum.TextYAlignment.Top
    blockInstr.Parent = InstructPage
    
    -- Visual Instructions
    addLabel(InstructPage, "—— VISUAL (Визуал) ——")
    
    local visInstr = Instance.new("TextLabel")
    visInstr.Size = UDim2.new(0, 460, 0, 160)
    visInstr.BackgroundTransparency = 1
    visInstr.Text = [[
👁️ Player ESP - Подсветка игроков. Показывает:
   - Boxes - рамки вокруг игроков
   - Names - имена игроков
   - Distance - расстояние до игроков
   - Health - здоровье игроков (полоска)

💡 Full Bright - Полная яркость. Убирает тени и делает карту светлой.

🔭 FOV - Поле зрения. Меняет угол обзора камеры.

🌫️ No Fog - Убирает туман. Карта полностью видна.

🟦 Chams - Подсветка игроков через стены (ForceField).

🩻 X-Ray - Рентген. Делает все объекты прозрачными.
]]
    visInstr.TextColor3 = Color3.fromRGB(200, 200, 200)
    visInstr.Font = Enum.Font.SourceSans
    visInstr.TextSize = 11
    visInstr.TextXAlignment = Enum.TextXAlignment.Left
    visInstr.TextYAlignment = Enum.TextYAlignment.Top
    visInstr.Parent = InstructPage
    
    -- Combat Instructions
    addLabel(InstructPage, "—— COMBAT (Бой) ——")
    
    local combInstr = Instance.new("TextLabel")
    combInstr.Size = UDim2.new(0, 460, 0, 140)
    combInstr.BackgroundTransparency = 1
    combInstr.Text = [[
🎯 Aimbot - Авто-прицеливание. Автоматически наводит камеру на ближайшего игрока.
   FOV - радиус захвата цели
   Smoothness - плавность наведения

🔫 Trigger Bot - Авто-выстрел при наведении на цель.

🤫 Silent Aim - Тихое прицеливание. Пули летят в цель без поворота камеры.

⚔️ Kill Aura - Аура убийства. Атакует всех в радиусе.
   Range - радиус атаки
]]
    combInstr.TextColor3 = Color3.fromRGB(200, 200, 200)
    combInstr.Font = Enum.Font.SourceSans
    combInstr.TextSize = 11
    combInstr.TextXAlignment = Enum.TextXAlignment.Left
    combInstr.TextYAlignment = Enum.TextYAlignment.Top
    combInstr.Parent = InstructPage
    
    -- World Instructions
    addLabel(InstructPage, "—— WORLD (Мир) ——")
    
    local worldInstr = Instance.new("TextLabel")
    worldInstr.Size = UDim2.new(0, 460, 0, 120)
    worldInstr.BackgroundTransparency = 1
    worldInstr.Text = [[
🚀 FPS Booster - Повышает FPS. Упрощает графику игры.

⏰ Anti-AFK - Защита от AFK. Персонаж не уходит в AFK.

🕐 Time Changer - Меняет время суток. Слайдер от 0 до 24 часов.

🌍 Gravity Changer - Меняет гравитацию. 196.2 - стандартная гравитация Roblox.
]]
    worldInstr.TextColor3 = Color3.fromRGB(200, 200, 200)
    worldInstr.Font = Enum.Font.SourceSans
    worldInstr.TextSize = 11
    worldInstr.TextXAlignment = Enum.TextXAlignment.Left
    worldInstr.TextYAlignment = Enum.TextYAlignment.Top
    worldInstr.Parent = InstructPage
    
    -- Misc Instructions
    addLabel(InstructPage, "—— MISC (Разное) ——")
    
    local miscInstr = Instance.new("TextLabel")
    miscInstr.Size = UDim2.new(0, 460, 0, 80)
    miscInstr.BackgroundTransparency = 1
    miscInstr.Text = [[
💬 Open Chat - Открывает окно ввода чата. Пиши сообщение, жми Enter или Send.

👁️ Chat Spy - Слежка за чатом других игроков.

🤐 Silent Chat - Тихий чат. Сообщения не видны другим.
]]
    miscInstr.TextColor3 = Color3.fromRGB(200, 200, 200)
    miscInstr.Font = Enum.Font.SourceSans
    miscInstr.TextSize = 11
    miscInstr.TextXAlignment = Enum.TextXAlignment.Left
    miscInstr.TextYAlignment = Enum.TextYAlignment.Top
    miscInstr.Parent = InstructPage
    
    -- Keybinds Instructions
    addLabel(InstructPage, "—— KEYBINDS (Клавиши) ——")
    
    local keyInstr = Instance.new("TextLabel")
    keyInstr.Size = UDim2.new(0, 460, 0, 60)
    keyInstr.BackgroundTransparency = 1
    keyInstr.Text = [[
NumPad1 - Создать блок
NumPad2 - Очистить блоки
NumPad3 - Телепорт к курсору
RightShift - Скрыть/показать GUI
]]
    keyInstr.TextColor3 = Color3.fromRGB(200, 200, 200)
    keyInstr.Font = Enum.Font.SourceSans
    keyInstr.TextSize = 11
    keyInstr.TextXAlignment = Enum.TextXAlignment.Left
    keyInstr.TextYAlignment = Enum.TextYAlignment.Top
    keyInstr.Parent = InstructPage
    
    -- // Drag functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
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

-- // Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.KeypadOne then
        spawnBlockUnder()
    elseif input.KeyCode == Enum.KeyCode.KeypadTwo then
        clearBlocks()
    elseif input.KeyCode == Enum.KeyCode.KeypadThree then
        teleportToCursor(); notify("Teleport", "Done!", 1)
    elseif input.KeyCode == Enum.KeyCode.RightShift then
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
end)

-- // Initialize
createGUI()
notify("PRO CHEAT HUB v3.2", "by mcherenkovYT | RightShift: Toggle GUI", 6)
