--[[
    XDHub: The Animal Hospital Utility Script (v2.2)
    Features:
        - Auto Heartbeat Minigame
        - Instant Proximity Prompts (Universal via HoldDuration = 0)
        - Diagnostic Room ESP (Cyan)
        - Patient & Anomaly ESP (Green for Real, Red for Fake/Anomaly/Skinwalker)
        - Infinite Sanity (Maintains Sanity at 100%)
        - Speed Hack (Toggleable WalkSpeed 30)
        - Safe Shutdown (Cleans all loops, hooks, connections, GUI, and highlights)
--]]
 
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")
 
local LocalPlayer = Players.LocalPlayer
local Net = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net")
 
-- Script State & Tracking
local ScriptActive = true
local Connections = {}
local Toggles = {
    AutoHeartbeat = false,
    InstantPrompt = false,
    RoomESP = false,
    NpcESP = false,
    InfSanity = false,
    SpeedHack = false
}
local Highlights = {}
local BillboardGuis = {}
 
-- Utility: Track Connections for Cleanup
local function track(conn)
    table.insert(Connections, conn)
    return conn
end
 
-- ESP Cleanup Helper
local function clearESP()
    for _, hl in pairs(Highlights) do
        if hl then pcall(function() hl:Destroy() end) end
    end
    table.clear(Highlights)
 
    for _, gui in pairs(BillboardGuis) do
        if gui then pcall(function() gui:Destroy() end) end
    end
    table.clear(BillboardGuis)
end
 
-- Restore Proximity Prompts HoldDuration
local function restorePrompts()
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local original = prompt:GetAttribute("OriginalHoldDuration")
            if original then
                prompt.HoldDuration = original
                prompt:SetAttribute("OriginalHoldDuration", nil)
            end
        end
    end
end
 
-- --- FEATURES ---
 
-- 1. Auto Heartbeat Minigame
local function initAutoHeartbeat()
    local heartbeatEvent = Net:WaitForChild("RE/StartHeartbeatMinigame")
    local completeEvent = Net:WaitForChild("RE/HeartbeatMinigameComplete")
 
    track(heartbeatEvent.OnClientEvent:Connect(function()
        if Toggles.AutoHeartbeat and ScriptActive then
            task.wait(0.2) -- Human-like delay
            completeEvent:FireServer(true, true)
        end
    end))
end
 
-- 2. Instant Proximity Prompts (Universal method)
local function initInstantPrompts()
    track(ProximityPromptService.PromptShown:Connect(function(prompt)
        if Toggles.InstantPrompt and ScriptActive then
            if not prompt:GetAttribute("OriginalHoldDuration") then
                prompt:SetAttribute("OriginalHoldDuration", prompt.HoldDuration)
            end
            prompt.HoldDuration = 0
        end
    end))
end
 
-- Apply instant prompt toggling dynamically to current visible prompts
local function updatePromptsState(enabled)
    if enabled then
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                if not prompt:GetAttribute("OriginalHoldDuration") then
                    prompt:SetAttribute("OriginalHoldDuration", prompt.HoldDuration)
                end
                prompt.HoldDuration = 0
            end
        end
    else
        restorePrompts()
    end
end
 
-- Check if NPC is an Anomaly
local function isNpcAnomaly(npc)
    -- Check Fake attribute
    local isFake = npc:GetAttribute("Fake")
    if isFake == true or isFake == "true" then
        return true
    end
 
    -- Check Skinwalker attribute
    local isSkinwalker = npc:GetAttribute("Skinwalker")
    if isSkinwalker == true or isSkinwalker == "true" then
        return true
    end
 
    -- Check tags
    if CollectionService:HasTag(npc, "Skinwalker") or 
       CollectionService:HasTag(npc, "SkinwalkerMonster") or 
       CollectionService:HasTag(npc, "GhostAnomaly") then
        return true
    end
 
    -- Check name patterns
    local lowerName = npc.Name:lower()
    if lowerName:find("monster") or lowerName:find("ghost") or lowerName:find("anomaly") then
        return true
    end
 
    return false
end
 
-- Check if NPC is a Patient
local function isNpcPatient(npc)
    local isPatient = npc:GetAttribute("IsPatient")
    if isPatient == true or isPatient == "true" then
        return true
    end
 
    if CollectionService:HasTag(npc, "ActivePatient") then
        return true
    end
 
    return false
end
 
-- 3. ESP (Rooms & NPCs)
local function updateESP()
    clearESP()
    if not ScriptActive then return end
 
    -- Diagnostic Rooms ESP
    if Toggles.RoomESP then
        local rooms = workspace:FindFirstChild("Rooms")
        local medical = rooms and rooms:FindFirstChild("Medical")
        if medical then
            for _, room in ipairs(medical:GetChildren()) do
                local minigame = room:FindFirstChild("Minigame")
                if minigame then
                    for _, model in ipairs(minigame:GetChildren()) do
                        if model:IsA("Model") and (model.Name == "Monitor" or model.Name == "Bed" or model.Name == "Analyzer") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "XDHub_RoomESP"
                            hl.FillColor = Color3.fromRGB(0, 180, 255)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.6
                            hl.OutlineTransparency = 0.2
                            hl.Adornee = model
                            hl.Parent = model
                            table.insert(Highlights, hl)
                        end
                    end
                end
            end
        end
    end
 
    -- Patient & Anomaly ESP
    if Toggles.NpcESP then
        local npcs = workspace:FindFirstChild("NPCs")
        if npcs then
            for _, npc in ipairs(npcs:GetChildren()) do
                if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                    local isAnomaly = isNpcAnomaly(npc)
                    local isPatient = isNpcPatient(npc)
                    local room = npc:GetAttribute("DesignatedRoom") or "Lobby"
                    local treated = npc:GetAttribute("Treated") or npc:GetAttribute("IsCured")
 
                    local color
                    local labelText
 
                    if isAnomaly then
                        color = Color3.fromRGB(255, 30, 30) -- Red for Anomaly
                        labelText = "⚠️ [ANOMALY] " .. npc.Name
                    elseif isPatient then
                        color = Color3.fromRGB(0, 255, 127) -- Green for Real
                        labelText = "[Patient] " .. npc.Name
                    else
                        -- Not a patient and not a known anomaly
                        continue
                    end
 
                    if treated == true or treated == "true" then
                        labelText = labelText .. " (Treated)"
                    else
                        labelText = labelText .. " (Room: " .. tostring(room) .. ")"
                    end
 
                    -- Highlight Model
                    local hl = Instance.new("Highlight")
                    hl.Name = "XDHub_NpcESP"
                    hl.FillColor = color
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0.1
                    hl.Adornee = npc
                    hl.Parent = npc
                    table.insert(Highlights, hl)
 
                    -- Overhead Label
                    local bill = Instance.new("BillboardGui")
                    bill.Name = "XDHub_Billboard"
                    bill.Adornee = npc:FindFirstChild("Head") or npc.HumanoidRootPart
                    bill.Size = UDim2.new(0, 200, 0, 50)
                    bill.AlwaysOnTop = true
                    bill.StudsOffset = Vector3.new(0, 3, 0)
 
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = labelText
                    textLabel.TextColor3 = color
                    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.TextSize = 12
                    textLabel.Parent = bill
 
                    bill.Parent = npc.HumanoidRootPart
                    table.insert(BillboardGuis, bill)
                end
            end
        end
    end
end
 
-- 4. Infinite Sanity
local function initSanity()
    track(LocalPlayer:GetAttributeChangedSignal("Sanity"):Connect(function()
        if Toggles.InfSanity and ScriptActive then
            local currentSanity = LocalPlayer:GetAttribute("Sanity")
            if currentSanity and currentSanity < 100 then
                LocalPlayer:SetAttribute("Sanity", 100)
            end
        end
    end))
    if Toggles.InfSanity then
        LocalPlayer:SetAttribute("Sanity", 100)
    end
end
 
-- 5. Speed Hack Loop
task.spawn(function()
    while ScriptActive do
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Toggles.SpeedHack then
                hum.WalkSpeed = 30
            end
        end
        task.wait(0.2)
    end
end)
 
-- --- USER INTERFACE ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XDHub_AnimalHospital"
ScreenGui.ResetOnSpawn = false
 
local targetParent = (RunService:IsStudio() or not pcall(function() ScreenGui.Parent = CoreGui end)) and LocalPlayer:WaitForChild("PlayerGui") or CoreGui
ScreenGui.Parent = targetParent
 
-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 420)
Frame.Position = UDim2.new(0.5, -160, 0.5, -210)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
 
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 14)
FrameCorner.Parent = Frame
 
-- Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "XDHub: The Animal Hospital"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame
 
-- Divider Line
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.9, 0, 0, 1)
Divider.Position = UDim2.new(0.05, 0, 0, 45)
Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Divider.BorderSizePixel = 0
Divider.Parent = Frame
 
-- Scrolling container
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(0.9, 0, 0.68, 0)
Scroll.Position = UDim2.new(0.05, 0, 0, 55)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 380)
Scroll.ScrollBarThickness = 4
Scroll.Parent = Frame
 
local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.Parent = Scroll
 
-- Toggle Builder
local function createToggle(name, displayName, defaultVal, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 42)
    button.BackgroundColor3 = defaultVal and Color3.fromRGB(35, 95, 60) or Color3.fromRGB(25, 25, 30)
    button.Text = displayName .. ": " .. (defaultVal and "ON" or "OFF")
    button.TextColor3 = Color3.fromRGB(240, 240, 240)
    button.TextSize = 13
    button.Font = Enum.Font.GothamSemibold
    button.Parent = Scroll
 
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button
 
    button.MouseButton1Click:Connect(function()
        Toggles[name] = not Toggles[name]
        button.BackgroundColor3 = Toggles[name] and Color3.fromRGB(35, 95, 60) or Color3.fromRGB(25, 25, 30)
        button.Text = displayName .. ": " .. (Toggles[name] and "ON" or "OFF")
        callback(Toggles[name])
    end)
end
 
-- Populate UI Toggles
createToggle("AutoHeartbeat", "Auto Heartbeat Minigame", Toggles.AutoHeartbeat, function() end)
createToggle("InstantPrompt", "Instant Proximity Prompts", Toggles.InstantPrompt, function(val)
    updatePromptsState(val)
end)
createToggle("RoomESP", "Diagnostic Room ESP", Toggles.RoomESP, function() updateESP() end)
createToggle("NpcESP", "Patient & Anomaly ESP", Toggles.NpcESP, function() updateESP() end)
createToggle("InfSanity", "Infinite Sanity", Toggles.InfSanity, function(val)
    if val then LocalPlayer:SetAttribute("Sanity", 100) end
end)
createToggle("SpeedHack", "Speed Hack (WalkSpeed 30)", Toggles.SpeedHack, function(val)
    if not val then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)
 
-- Safe Shutdown Button
local ShutdownBtn = Instance.new("TextButton")
ShutdownBtn.Size = UDim2.new(0.9, 0, 0, 38)
ShutdownBtn.Position = UDim2.new(0.05, 0, 0.88, 0)
ShutdownBtn.BackgroundColor3 = Color3.fromRGB(130, 35, 35)
ShutdownBtn.Text = "Safe Shutdown"
ShutdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShutdownBtn.TextSize = 13
ShutdownBtn.Font = Enum.Font.GothamBold
ShutdownBtn.Parent = Frame
 
local sdCorner = Instance.new("UICorner")
sdCorner.CornerRadius = UDim.new(0, 8)
sdCorner.Parent = ShutdownBtn
 
-- Safe Shutdown Action
local function shutdownScript()
    ScriptActive = false
 
    -- Disconnect connections
    for _, conn in ipairs(Connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    table.clear(Connections)
 
    -- Restore Humanoid WalkSpeed
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
 
    -- Restore proximity prompts
    restorePrompts()
 
    -- Destroy ESP objects
    clearESP()
 
    -- Destroy UI
    ScreenGui:Destroy()
    print("[XDHub] Script successfully shut down and all elements cleaned up.")
end
 
ShutdownBtn.MouseButton1Click:Connect(shutdownScript)
 
-- Initialize listeners
initAutoHeartbeat()
initInstantPrompts()
initSanity()
 
-- Periodic ESP Refresh Loop
task.spawn(function()
    while ScriptActive do
        if Toggles.RoomESP or Toggles.NpcESP then
            updateESP()
        end
        task.wait(1.5)
    end
end)