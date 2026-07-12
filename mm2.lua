-- MM2 Script - Mobile Optimized (Delta Executor)
-- Features: Auto Knife, ESP, Sheriff Aimbot, Invisible Troll
-- Loadstring format
 
 
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
 
 
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Script_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer.PlayerGui end
 
 
-- State Variables
local autoKnifeEnabled = false
local aimbotEnabled = false
local invisTrollEnabled = false
local espEnabled = true
local espObjects = {}
local gunESPObjects = {}
 
 
-- Colors
local MURDER_COLOR = Color3.fromRGB(255, 50, 50)
local SHERIFF_COLOR = Color3.fromRGB(50, 150, 255)
local INNOCENT_COLOR = Color3.fromRGB(50, 255, 50)
local GUN_COLOR = Color3.fromRGB(255, 215, 0)
 
 
-- Role Detection
local function getRole(player)
    local char = player.Character
    if not char then return "innocent" end
    -- Check for knife (murder has knife tool)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        if backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") then
            return "murder"
        end
        if backpack:FindFirstChild("Sheriff's Gun") or char:FindFirstChild("Sheriff's Gun") or
           backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") then
            return "sheriff"
        end
    end
    if char:FindFirstChild("Knife") then return "murder" end
    if char:FindFirstChild("Sheriff's Gun") or char:FindFirstChild("Gun") then return "sheriff" end
    return "innocent"
end
 
 
local function getLocalRole()
    return getRole(LocalPlayer)
end
 
 
-- ESP Functions
local function removeESP(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            pcall(function() obj:Destroy() end)
        end
        espObjects[player] = nil
    end
end
 
 
local function createESP(player)
    if player == LocalPlayer then return end
    removeESP(player)
    espObjects[player] = {}
 
 
local billboardGui = Instance.new("BillboardGui")
billboardGui.Name = "ESP_" .. player.Name
billboardGui.AlwaysOnTop = true
billboardGui.Size = UDim2.new(0, 120, 0, 50)
billboardGui.StudsOffset = Vector3.new(0, 3, 0)
billboardGui.Adornee = nil
 
local nameLabel = Instance.new("TextLabel")
nameLabel.BackgroundTransparency = 1
nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextScaled = true
nameLabel.TextStrokeTransparency = 0
nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
nameLabel.Parent = billboardGui
 
local roleLabel = Instance.new("TextLabel")
roleLabel.BackgroundTransparency = 1
roleLabel.Size = UDim2.new(1, 0, 0.4, 0)
roleLabel.Position = UDim2.new(0, 0, 0.6, 0)
roleLabel.Font = Enum.Font.Gotham
roleLabel.TextScaled = true
roleLabel.TextStrokeTransparency = 0
roleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
roleLabel.Parent = billboardGui
 
espObjects[player] = {billboardGui = billboardGui, nameLabel = nameLabel, roleLabel = roleLabel}
 
-- Highlight (outline)
local highlight = Instance.new("SelectionBox")
highlight.LineThickness = 0.05
highlight.SurfaceTransparency = 0.8
highlight.Name = "ESP_Highlight_" .. player.Name
highlight.Parent = Workspace
espObjects[player].highlight = highlight
 
local function attachESP()
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            billboardGui.Adornee = hrp
            billboardGui.Parent = hrp
            highlight.Adornee = char
        end
    end
end
 
attachESP()
if player.Character then
    player.Character.ChildAdded:Connect(function() attachESP() end)
end
player.CharacterAdded:Connect(function(char)
    wait(0.5)
    attachESP()
end)
 
end
 
 
local function updateESPColors()
    for player, objs in pairs(espObjects) do
        if player and player.Parent then
            local role = getRole(player)
            local color
            if role == "murder" then
                color = MURDER_COLOR
            elseif role == "sheriff" then
                color = SHERIFF_COLOR
            else
                color = INNOCENT_COLOR
            end
            if objs.nameLabel then
                objs.nameLabel.TextColor3 = color
                objs.nameLabel.Text = player.Name
            end
            if objs.roleLabel then
                objs.roleLabel.TextColor3 = color
                objs.roleLabel.Text = "[" .. role:upper() .. "]"
            end
            if objs.highlight then
                objs.highlight.Color3 = color
                local char = player.Character
                if char then
                    objs.highlight.Adornee = char
                else
                    objs.highlight.Adornee = nil
                end
            end
        end
    end
end
 
 
-- Gun ESP
local function createGunESP(part)
    if gunESPObjects[part] then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GunESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Adornee = part
    billboard.Parent = part
 
 
local label = Instance.new("TextLabel")
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.BackgroundTransparency = 0.4
label.Size = UDim2.new(1, 0, 1, 0)
label.Font = Enum.Font.GothamBold
label.Text = "\ud83d\udd2b GUN"
label.TextColor3 = GUN_COLOR
label.TextScaled = true
label.TextStrokeTransparency = 0
label.Parent = billboard
 
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.2, 0)
uiCorner.Parent = label
 
gunESPObjects[part] = billboard
 
end
 
 
local function scanForGuns()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
            if obj.Name:lower():find("gun") or obj.Name:lower():find("sheriff") then
                if not obj:IsDescendantOf(Players.LocalPlayer.Character or Instance.new("Part")) then
                    local found = false
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr.Character and obj:IsDescendantOf(plr.Character) then
                            found = true
                            break
                        end
                        if obj:IsDescendantOf(plr.Backpack) then
                            found = true
                            break
                        end
                    end
                    if not found then
                        createGunESP(obj)
                    end
                end
            end
        end
    end
    -- Cleanup old gun ESPs
    for part, billboard in pairs(gunESPObjects) do
        if not part or not part.Parent then
            pcall(function() billboard:Destroy() end)
            gunESPObjects[part] = nil
        end
    end
end
 
 
-- Auto Knife (Murder throws knife at nearest player)
local function throwKnife()
    local myRole = getLocalRole()
    if myRole ~= "murder" then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
 
 
local knife = char:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
if not knife then return end
 
-- Equip knife
local humanoid = char:FindFirstChildOfClass("Humanoid")
if humanoid then
    humanoid:EquipTool(knife)
end
 
-- Find nearest target
local nearest = nil
local nearestDist = math.huge
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer and plr.Character then
        local phrp = plr.Character:FindFirstChild("HumanoidRootPart")
        local phum = plr.Character:FindFirstChildOfClass("Humanoid")
        if phrp and phum and phum.Health > 0 then
            local dist = (hrp.Position - phrp.Position).Magnitude
            if dist < nearestDist then
                nearest = plr
                nearestDist = dist
            end
        end
    end
end
 
if nearest and nearest.Character then
    local targetHRP = nearest.Character:FindFirstChild("HumanoidRootPart")
    if targetHRP then
        -- Aim toward target
        local direction = (targetHRP.Position - hrp.Position).Unit
        local cf = CFrame.lookAt(hrp.Position, targetHRP.Position)
        hrp.CFrame = cf
 
        -- Fire knife via remote
        local throwRemote = nil
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("throw") or v.Name:lower():find("knife")) then
                throwRemote = v
                break
            end
        end
 
        if throwRemote then
            pcall(function()
                throwRemote:FireServer(targetHRP.Position)
            end)
        else
            -- Simulate mouse click on knife
            pcall(function()
                knife:Activate()
            end)
        end
    end
end
 
end
 
 
-- Sheriff Aimbot
local function shootTarget()
    local myRole = getLocalRole()
    if myRole ~= "sheriff" then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
 
 
local gun = char:FindFirstChild("Sheriff's Gun") or char:FindFirstChild("Gun")
           or LocalPlayer.Backpack:FindFirstChild("Sheriff's Gun")
           or LocalPlayer.Backpack:FindFirstChild("Gun")
if not gun then return end
 
local humanoid = char:FindFirstChildOfClass("Humanoid")
if humanoid then
    humanoid:EquipTool(gun)
end
 
-- Find murder
local target = nil
local nearestDist = math.huge
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer and plr.Character then
        local role = getRole(plr)
        if role == "murder" then
            local phrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local phum = plr.Character:FindFirstChildOfClass("Humanoid")
            if phrp and phum and phum.Health > 0 then
                local dist = (hrp.Position - phrp.Position).Magnitude
                if dist < nearestDist then
                    target = plr
                    nearestDist = dist
                end
            end
        end
    end
end
 
if not target then
    -- Fallback: nearest player
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local phrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local phum = plr.Character:FindFirstChildOfClass("Humanoid")
            if phrp and phum and phum.Health > 0 then
                local dist = (hrp.Position - phrp.Position).Magnitude
                if dist < nearestDist then
                    target = plr
                    nearestDist = dist
                end
            end
        end
    end
end
 
if target and target.Character then
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if targetHRP then
        hrp.CFrame = CFrame.lookAt(hrp.Position, targetHRP.Position)
        -- Fire gun remote
        local shootRemote = nil
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:lower():find("shoot") or v.Name:lower():find("fire") or v.Name:lower():find("gun")) then
                shootRemote = v
                break
            end
        end
        if shootRemote then
            pcall(function()
                shootRemote:FireServer(targetHRP.Position)
            end)
        else
            pcall(function()
                gun:Activate()
            end)
        end
    end
end
 
end
 
 
-- ===================== GUI =====================
 
 
-- Main Frame (draggable)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 230, 0, 260)
MainFrame.Position = UDim2.new(0, 20, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
 
 
local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 14)
UICornerMain.Parent = MainFrame
 
 
local UIStrokeMain = Instance.new("UIStroke")
UIStrokeMain.Color = Color3.fromRGB(200, 50, 50)
UIStrokeMain.Thickness = 2
UIStrokeMain.Parent = MainFrame
 
 
-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
 
 
local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 14)
UICornerTitle.Parent = TitleBar
 
 
-- Fix bottom corners of title
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar
 
 
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "\ud83d\udd2a MM2 Script"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextScaled = true
TitleLabel.Parent = TitleBar
 
 
-- Drag functionality (mobile-friendly)
local dragging = false
local dragStart, startPos
 
 
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
 
 
TitleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
 
 
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
 
 
-- Button Creator Function
local function createButton(parent, text, color, posY, size)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(0, 200, 0, 44)
    btn.Position = UDim2.new(0.5, 0, 0, posY)
    btn.AnchorPoint = Vector2.new(0.5, 0)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Parent = parent
 
 
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = btn
 
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1
stroke.Transparency = 0.7
stroke.Parent = btn
 
return btn
 
end
 
 
-- Throw Knife Button
local throwKnifeBtn = createButton(MainFrame, "\ud83d\udd2a Throw Knife", Color3.fromRGB(180, 30, 30), 48)
 
 
throwKnifeBtn.MouseButton1Click:Connect(function()
    if autoKnifeEnabled then
        autoKnifeEnabled = false
        throwKnifeBtn.Text = "\ud83d\udd2a Throw Knife"
        throwKnifeBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    else
        autoKnifeEnabled = true
        throwKnifeBtn.Text = "\ud83d\udd2a Throw Knife: ON"
        throwKnifeBtn.BackgroundColor3 = Color3.fromRGB(230, 60, 60)
    end
end)
 
 
throwKnifeBtn.TouchTap:Connect(function()
    throwKnifeBtn.MouseButton1Click:Fire()
end)
 
 
-- Shoot Murder Button (Sheriff Aimbot)
local shootBtn = createButton(MainFrame, "\ud83d\udd2b Shoot Murder", Color3.fromRGB(30, 90, 200), 102)
 
 
shootBtn.MouseButton1Click:Connect(function()
    if aimbotEnabled then
        aimbotEnabled = false
        shootBtn.Text = "\ud83d\udd2b Shoot Murder"
        shootBtn.BackgroundColor3 = Color3.fromRGB(30, 90, 200)
    else
        aimbotEnabled = true
        shootBtn.Text = "\ud83d\udd2b Shoot Murder: ON"
        shootBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 255)
    end
end)
 
 
-- ESP Toggle Button
local espBtn = createButton(MainFrame, "\ud83d\udc41 ESP: ON", Color3.fromRGB(30, 150, 80), 156)
 
 
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espBtn.Text = "\ud83d\udc41 ESP: ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(30, 150, 80)
        for _, plr in pairs(Players:GetPlayers()) do
            createESP(plr)
        end
    else
        espBtn.Text = "\ud83d\udc41 ESP: OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        for plr, _ in pairs(espObjects) do
            removeESP(plr)
        end
    end
end)
 
 
-- Invisible Troll Button (small)
local invisBtn = createButton(MainFrame, "\ud83d\udc7b Invisible: OFF", Color3.fromRGB(80, 40, 120), 210, UDim2.new(0, 200, 0, 34))
 
 
invisBtn.MouseButton1Click:Connect(function()
    invisTrollEnabled = not invisTrollEnabled
    if invisTrollEnabled then
        invisBtn.Text = "\ud83d\udc7b Invisible: ON"
        invisBtn.BackgroundColor3 = Color3.fromRGB(140, 60, 200)
        -- Troll: make character transparent
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0.95
                elseif part:IsA("Decal") then
                    part.Transparency = 0.95
                end
            end
        end
    else
        invisBtn.Text = "\ud83d\udc7b Invisible: OFF"
        invisBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                elseif part:IsA("Decal") then
                    part.Transparency = 0
                end
            end
        end
    end
end)
 
 
-- Initialize ESP for existing players
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        createESP(plr)
    end
end
 
 
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        wait(1)
        if espEnabled then createESP(plr) end
    end)
    if espEnabled then createESP(plr) end
end)
 
 
Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)
 
 
-- Restore transparency when character respawns
LocalPlayer.CharacterAdded:Connect(function(char)
    if invisTrollEnabled then
        wait(0.5)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 0.95
            end
        end
    end
end)
 
 
-- Main Loop
RunService.Heartbeat:Connect(function()
    -- Auto Knife
    if autoKnifeEnabled then
        local role = getLocalRole()
        if role == "murder" then
            throwKnife()
        end
    end
 
 
-- Aimbot
if aimbotEnabled then
    local role = getLocalRole()
    if role == "sheriff" then
        shootTarget()
    end
end
 
-- ESP Update
if espEnabled then
    updateESPColors()
end
 
-- Gun ESP Scan (every ~0.5s equivalent via throttle)
 
end)
 
 
-- Gun ESP scan loop
spawn(function()
    while true do
        wait(0.5)
        if espEnabled then
            scanForGuns()
        end
    end
end)