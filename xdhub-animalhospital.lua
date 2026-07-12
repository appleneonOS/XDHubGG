-- =====================================================================
-- SHELLY'S WORLD v4.9 + XDHUB: ANIMAL HOSPITAL EDITION
-- =====================================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("ShellysWorldV49") then
    PlayerGui.ShellysWorldV49:Destroy()
end

local ShellysWorldUI = Instance.new("ScreenGui")
ShellysWorldUI.Name = "ShellysWorldV49"
ShellysWorldUI.Parent = PlayerGui
ShellysWorldUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ShellysWorldUI.ResetOnSpawn = false

-- --- Core Configuration & Timing Sync ---
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local COLOR_PANEL_BG = Color3.fromRGB(24, 18, 14)       
local TRANS_PANEL = 0.25 

local COLOR_DISPLAY_BG = Color3.fromRGB(33, 26, 21)     
local TRANS_DISPLAY = 0.40

local COLOR_OFF_BG = Color3.fromRGB(48, 40, 35)       
local COLOR_OFF_STROKE = Color3.fromRGB(75, 65, 58)
local TRANS_OFF = 0.30

local COLOR_ON_BG = Color3.fromRGB(143, 91, 53)         
local COLOR_ON_STROKE = Color3.fromRGB(184, 122, 79)

local COLOR_WARN_BG = Color3.fromRGB(180, 50, 50)
local COLOR_WARN_STROKE = Color3.fromRGB(220, 80, 80)

-- --- Main Dashboard Panel ---
local MainPanel = Instance.new("ImageLabel")
MainPanel.Name = "MainPanel"
MainPanel.Parent = ShellysWorldUI
MainPanel.BackgroundColor3 = COLOR_PANEL_BG
MainPanel.BackgroundTransparency = TRANS_PANEL
MainPanel.Position = UDim2.new(0.5, -200, 0.4, -175)
MainPanel.Size = UDim2.new(0, 400, 0, 350)
MainPanel.ZIndex = 5
MainPanel.ScaleType = Enum.ScaleType.Crop
MainPanel.Image = "" 
MainPanel.ImageTransparency = 1 

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 9)
MainCorner.Parent = MainPanel

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLOR_ON_STROKE        
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.2
MainStroke.Parent = MainPanel

-- --- Header Banner ---
local TitleHeader = Instance.new("TextLabel")
TitleHeader.Name = "TitleHeader"
TitleHeader.Parent = MainPanel
TitleHeader.BackgroundTransparency = 1
TitleHeader.Size = UDim2.new(1, 0, 0, 45)
TitleHeader.Font = Enum.Font.SourceSansBold
TitleHeader.Text = "🐾 XDHUB | ANIMAL HOSPITAL"
TitleHeader.TextColor3 = Color3.fromRGB(235, 195, 150) 
TitleHeader.TextSize = 16
TitleHeader.TextXAlignment = Enum.TextXAlignment.Left
TitleHeader.ZIndex = 6

local TitlePadding = Instance.new("UIPadding")
TitlePadding.PaddingLeft = UDim.new(0, 15)
TitlePadding.Parent = TitleHeader

local AccentLine = Instance.new("Frame")
AccentLine.Name = "AccentLine"
AccentLine.Parent = TitleHeader
AccentLine.BackgroundColor3 = COLOR_ON_BG
AccentLine.BackgroundTransparency = 0.6
AccentLine.BorderSizePixel = 0
AccentLine.Position = UDim2.new(-0.01, 0, 1, -1)
AccentLine.Size = UDim2.new(0.92, 0, 0, 1)
AccentLine.ZIndex = 6

-- --- Floating Reopen Icon ---
local OpenIcon = Instance.new("TextButton")
OpenIcon.Name = "OpenIcon"
OpenIcon.Parent = ShellysWorldUI
OpenIcon.BackgroundColor3 = Color3.fromRGB(110, 70, 40)
OpenIcon.BackgroundTransparency = 0.2
OpenIcon.Position = UDim2.new(0, 20, 0.4, 0)
OpenIcon.Size = UDim2.new(0, 50, 0, 50)
OpenIcon.Font = Enum.Font.SourceSansBold
OpenIcon.Text = "🐾"                                  
OpenIcon.TextColor3 = Color3.fromRGB(255, 235, 190)
OpenIcon.TextSize = 28
OpenIcon.ZIndex = 10
OpenIcon.Visible = false

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0)
IconCorner.Parent = OpenIcon

local IconStroke = Instance.new("UIStroke")
IconStroke.Color = Color3.fromRGB(75, 45, 25)
IconStroke.Thickness = 2
IconStroke.Parent = OpenIcon

-- --- Navigation Logic ---
local function toggleUI(showPanel)
    if showPanel then
        OpenIcon.Visible = false
        MainPanel.Visible = true
        MainPanel:TweenPosition(UDim2.new(0.5, -200, 0.4, -175), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
    else
        MainPanel:TweenPosition(UDim2.new(0.5, -200, -0.5, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.3, true, function()
            MainPanel.Visible = false
            OpenIcon.Visible = true
        end)
    end
end

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainPanel
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(231, 76, 60)
CloseButton.TextSize = 18
CloseButton.ZIndex = 6

CloseButton.MouseButton1Click:Connect(function() toggleUI(false) end)
OpenIcon.MouseButton1Click:Connect(function() toggleUI(true) end)

-- --- Left Navigation Container ---
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainPanel
Sidebar.BackgroundTransparency = 1
Sidebar.Position = UDim2.new(0, 10, 0, 55)
Sidebar.Size = UDim2.new(0, 85, 1, -65)
Sidebar.ZIndex = 6

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Parent = Sidebar
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 4)

-- --- Main Panel Dynamic Canvas ---
local DisplayArea = Instance.new("Frame")
DisplayArea.Name = "DisplayArea"
DisplayArea.Parent = MainPanel
DisplayArea.BackgroundColor3 = COLOR_DISPLAY_BG
DisplayArea.BackgroundTransparency = TRANS_DISPLAY
DisplayArea.Position = UDim2.new(0, 100, 0, 55)
DisplayArea.Size = UDim2.new(1, -110, 1, -65)
DisplayArea.ZIndex = 6

local AreaCorner = Instance.new("UICorner")
AreaCorner.CornerRadius = UDim.new(0, 6)
AreaCorner.Parent = DisplayArea

local AreaStroke = Instance.new("UIStroke")
AreaStroke.Color = Color3.fromRGB(255, 255, 255)
AreaStroke.Thickness = 1
AreaStroke.Transparency = 0.94
AreaStroke.Parent = DisplayArea

-- --- Viewport Allocation Matrices ---
local Pages = {}

local function createPage(pageName)
    local PageFrame = Instance.new("ScrollingFrame")
    PageFrame.Name = pageName .. "Page"
    PageFrame.Parent = DisplayArea
    PageFrame.BackgroundTransparency = 1
    PageFrame.Size = UDim2.new(1, 0, 1, 0)
    PageFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
    PageFrame.ScrollBarThickness = 2
    PageFrame.ScrollBarImageColor3 = COLOR_ON_STROKE
    PageFrame.Visible = false
    PageFrame.ZIndex = 7
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = PageFrame
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 6)
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 6)
    UIPadding.Parent = PageFrame
    
    Pages[pageName] = PageFrame
    return PageFrame
end

local function createTabButton(targetPage, displayTitle, layoutIndex)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = targetPage .. "TabBtn"
    TabBtn.Parent = Sidebar
    TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.BackgroundTransparency = 0.96
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.Text = displayTitle
    TabBtn.TextColor3 = Color3.fromRGB(140, 135, 130)
    TabBtn.TextSize = 12
    TabBtn.LayoutOrder = layoutIndex
    TabBtn.ZIndex = 7
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 5)
    TabCorner.Parent = TabBtn
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, page in pairs(Pages) do page.Visible = false end
        for _, btn in ipairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundTransparency = 0.96
                btn.TextColor3 = Color3.fromRGB(140, 135, 130)
            end
        end
        Pages[targetPage].Visible = true
        TabBtn.BackgroundTransparency = 0.90
        TabBtn.TextColor3 = Color3.fromRGB(235, 195, 150)
    end)
end

createPage("Main")
createPage("Auto")
createPage("ESP")
createPage("Custom")

createTabButton("Main", "⚡ Main", 1)
createTabButton("Auto", "🤖 Auto", 2)
createTabButton("ESP", "👁️ ESP", 3)
createTabButton("Custom", "🎨 Custom", 4)

Pages.Main.Visible = true
Sidebar:FindFirstChild("MainTabBtn").BackgroundTransparency = 0.90
Sidebar:FindFirstChild("MainTabBtn").TextColor3 = Color3.fromRGB(235, 195, 150)

-- =====================================================================
-- INTERFACE CORE FACTORY BUILDERS
-- =====================================================================

local function addActionButton(targetPage, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.92, 0, 0, 32)
    Button.BackgroundColor3 = Color3.fromRGB(46, 36, 30)
    Button.BackgroundTransparency = 0.4
    Button.Font = Enum.Font.SourceSansBold
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(235, 225, 215)
    Button.TextSize = 13
    Button.Parent = Pages[targetPage]
    Button.ZIndex = 8
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Button
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.92
    Stroke.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        TweenService:Create(Button, TWEEN_FAST, {BackgroundTransparency = 0.2}):Play()
        task.wait(0.1)
        TweenService:Create(Button, TWEEN_FAST, {BackgroundTransparency = 0.4}):Play()
        callback()
    end)
end

local function addToggle(targetPage, text, callback, isBroken)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(0.92, 0, 0, 36)
    Row.BackgroundTransparency = 1
    Row.Parent = Pages[targetPage]
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.SourceSansBold
    Label.Text = text
    Label.TextColor3 = isBroken and Color3.fromRGB(255, 150, 150) or Color3.fromRGB(205, 195, 185)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row
    Label.ZIndex = 8
    
    if isBroken then
        local WarningMark = Instance.new("TextLabel")
        WarningMark.Size = UDim2.new(0, 35, 1, 0)
        WarningMark.Position = UDim2.new(0.65, 5, 0, 0)
        WarningMark.BackgroundTransparency = 1
        WarningMark.Font = Enum.Font.SourceSansBold
        WarningMark.Text = "⚠️"
        WarningMark.TextColor3 = Color3.fromRGB(255, 200, 100)
        WarningMark.TextSize = 14
        WarningMark.TextXAlignment = Enum.TextXAlignment.Left
        WarningMark.Parent = Row
        WarningMark.ZIndex = 8
    end
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 38, 0, 18)
    Switch.Position = UDim2.new(1, -38, 0.5, -9)
    Switch.Text = "" 
    Switch.BackgroundColor3 = isBroken and COLOR_WARN_BG or COLOR_OFF_BG
    Switch.BackgroundTransparency = isBroken and 0.2 or TRANS_OFF
    Switch.Parent = Row
    Switch.ZIndex = 8
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(0, 4)
    SwitchCorner.Parent = Switch
    
    local SwitchStroke = Instance.new("UIStroke")
    SwitchStroke.Color = isBroken and COLOR_WARN_STROKE or COLOR_OFF_STROKE
    SwitchStroke.Thickness = 1
    SwitchStroke.Parent = Switch
    
    local state = false
    Switch.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(Switch, TWEEN_FAST, {BackgroundColor3 = isBroken and COLOR_WARN_BG or COLOR_ON_BG, BackgroundTransparency = isBroken and 0.1 or 0}):Play()
            TweenService:Create(SwitchStroke, TWEEN_FAST, {Color3 = isBroken and COLOR_WARN_STROKE or COLOR_ON_STROKE}):Play()
        else
            TweenService:Create(Switch, TWEEN_FAST, {BackgroundColor3 = isBroken and COLOR_WARN_BG or COLOR_OFF_BG, BackgroundTransparency = isBroken and 0.2 or TRANS_OFF}):Play()
            TweenService:Create(SwitchStroke, TWEEN_FAST, {Color3 = isBroken and COLOR_WARN_STROKE or COLOR_OFF_STROKE}):Play()
        end
        callback(state)
    end)
end

local function addInputBox(targetPage, placeholderText, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(0.92, 0, 0, 42)
    Row.BackgroundTransparency = 1
    Row.Parent = Pages[targetPage]
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, 0, 0, 32)
    TextBox.Position = UDim2.new(0, 0, 0.5, -16)
    TextBox.BackgroundColor3 = Color3.fromRGB(36, 28, 24)
    TextBox.BackgroundTransparency = 0.5
    TextBox.Font = Enum.Font.SourceSansBold
    TextBox.PlaceholderText = placeholderText
    TextBox.PlaceholderColor3 = Color3.fromRGB(120, 110, 100)
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 13
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = Row
    TextBox.ZIndex = 8
    
    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 5)
    BoxCorner.Parent = TextBox
    
    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = Color3.fromRGB(90, 75, 65)
    BoxStroke.Thickness = 1
    BoxStroke.Parent = TextBox
    
    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and TextBox.Text ~= "" then callback(TextBox.Text) end
    end)
end

-- =====================================================================
-- GAMEPLAY AUTOMATION SYSTEMS Matrix
-- =====================================================================
local Features = {
    InstantPrompts = false,
    AutoCheckIn = false,
    InfiniteSanity = false,
    SpeedHack = false,
    AutoHeartbeat = false,
    NpcESP = false,
    RoomESP = false
}

local promptConns = {}
local promptOverrides = {}

local function overridePrompt(prompt)
    if not prompt then return end
    if not prompt:GetAttribute("OriginalHoldDuration") then
        prompt:SetAttribute("OriginalHoldDuration", prompt.HoldDuration)
    end
    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    prompt.Exclusive = false
    if prompt.MaxActivationDistance then
        prompt.MaxActivationDistance = 100
    end
    
    if not promptOverrides[prompt] then
        promptOverrides[prompt] = prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
            if Features.InstantPrompts and prompt.HoldDuration > 0 then
                prompt.HoldDuration = 0
            end
        end)
    end
end

local function overrideAllPrompts()
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            overridePrompt(prompt)
        end
    end
end

local function restoreAllPrompts()
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local orig = prompt:GetAttribute("OriginalHoldDuration")
            if orig then
                prompt.HoldDuration = orig
                prompt:SetAttribute("OriginalHoldDuration", nil)
            end
        end
    end
end

local function setupPromptSystem()
    for _, conn in pairs(promptConns) do
        pcall(function() conn:Disconnect() end)
    end
    promptConns = {}
    
    local c1 = Workspace.DescendantAdded:Connect(function(obj)
        if Features.InstantPrompts and obj:IsA("ProximityPrompt") then
            overridePrompt(obj)
        end
    end)
    table.insert(promptConns, c1)
    
    local c2 = ProximityPromptService.PromptShown:Connect(function(prompt)
        if Features.InstantPrompts then
            overridePrompt(prompt)
        end
    end)
    table.insert(promptConns, c2)
    
    overrideAllPrompts()
end

local function autoCheckIn()
    if not Features.AutoCheckIn then return end
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local reception = Workspace:FindFirstChild("Reception")
        if not reception then return end
        
        local parts = {}
        local triggers = reception:FindFirstChild("CheckInTriggers")
        if triggers then
            for _, v in ipairs(triggers:GetChildren()) do
                if v:IsA("BasePart") then table.insert(parts, v) end
            end
        else
            for _, v in ipairs(reception:GetDescendants()) do
                if v:IsA("BasePart") and string.find(v.Name:lower(), "check") then
                    table.insert(parts, v)
                end
            end
        end
        
        for _, part in ipairs(parts) do
            root.CFrame = part.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.2)
            for _, prompt in ipairs(reception:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    local dist = (prompt:GetPivot().Position - root.Position).Magnitude
                    if dist < 20 then
                        pcall(function() if prompt.Fire then prompt:Fire(LocalPlayer) end end)
                    end
                end
                if prompt:IsA("ClickDetector") then
                    local dist = (prompt:GetPivot().Position - root.Position).Magnitude
                    if dist < 20 then
                        pcall(function() prompt:FireClick(LocalPlayer) end)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

local function toggleSpeed(enabled)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = enabled and 30 or 16
    end
end

local function setupHeartbeat()
    local evt = ReplicatedStorage:FindFirstChild("RE/StartHeartbeatMinigame")
    if not evt then
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if string.find(obj.Name, "Heartbeat") then
                evt = obj
                break
            end
        end
    end
    if evt then
        evt.OnClientEvent:Connect(function()
            if Features.AutoHeartbeat then
                task.wait(0.2)
                local complete = ReplicatedStorage:FindFirstChild("RE/HeartbeatMinigameComplete")
                if complete then
                    complete:FireServer(true, true)
                end
            end
        end)
    end
end

local espObjects = {}
local function clearESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
end

local function updateESP()
    clearESP()
    if not Features.NpcESP and not Features.RoomESP then return end
    
    if Features.NpcESP then
        local npcs = Workspace:FindFirstChild("NPCs")
        if npcs then
            for _, npc in ipairs(npcs:GetChildren()) do
                if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                    local isAnomaly = npc:GetAttribute("Fake") or npc:GetAttribute("Skinwalker")
                    local color = isAnomaly and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(0, 255, 127)
                    
                    local hl = Instance.new("Highlight")
                    hl.FillColor = color
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0.1
                    hl.Adornee = npc