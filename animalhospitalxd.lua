-- Load Rayfield Safely
print("Loading Rayfield...")
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Failed to load Rayfield UI library.")
    return
end
print("Rayfield loaded.")

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "XDHub - Animal Hospital",
    Icon = 0,
    LoadingTitle = "Loading XDHub..",
    LoadingSubtitle = "by Shellae.",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "XDHub_AnimalHospital"
    },
    KeySystem = false,
    Discord = { Enabled = false }
})
print("Window created.")

-- ============ TABS ============
local MainTab = Window:CreateTab("Main", nil)
local VisualTab = Window:CreateTab("Visual", nil)
print("Tabs created.")

-- ============ SERVICES ============
local Net = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
print("Services obtained.")

-- ============ GLOBALS ============
local ScriptActive = true
local Toggles = {
    AutoHeartbeat = false,
    InstantPrompt = false,
    RoomESP = false,
    NpcESP = false,
    InfSanity = false
}

-- ESP storage
local Highlights = {}
local BillboardGuis = {}
print("Globals set.")

-- ============ HELPER FUNCTIONS ============

local function isNpcAnomaly(npc)
    if not npc then return false end
    local isFake = npc:GetAttribute("Fake")
    if isFake == true or isFake == "true" then return true end

    local isSkinwalker = npc:GetAttribute("Skinwalker")
    if isSkinwalker == true or isSkinwalker == "true" then return true end

    if CollectionService:HasTag(npc, "Skinwalker") or 
       CollectionService:HasTag(npc, "SkinwalkerMonster") or 
       CollectionService:HasTag(npc, "GhostAnomaly") then
        return true
    end

    local lowerName = npc.Name:lower()
    if lowerName:find("monster") or lowerName:find("ghost") or lowerName:find("anomaly") then
        return true
    end

    return false
end

local function isNpcPatient(npc)
    if not npc then return false end
    local isPatient = npc:GetAttribute("IsPatient")
    if isPatient == true or isPatient == "true" then return true end

    if CollectionService:HasTag(npc, "ActivePatient") then
        return true
    end

    return false
end
print("Helper functions defined.")

-- ============ ESP FUNCTIONS ============

local function clearESP()
    for _, obj in ipairs(Highlights) do
        if obj and obj.Parent then pcall(function() obj:Destroy() end) end
    end
    for _, obj in ipairs(BillboardGuis) do
        if obj and obj.Parent then pcall(function() obj:Destroy() end) end
    end
    Highlights = {}
    BillboardGuis = {}
end

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
                            hl.Name = "Shellae_RoomESP"
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
                        color = Color3.fromRGB(255, 30, 30)
                        labelText = "⚠️ [ANOMALY] " .. npc.Name
                    elseif isPatient then
                        color = Color3.fromRGB(0, 255, 127)
                        labelText = "[Patient] " .. npc.Name
                    else
                        continue
                    end

                    if treated == true or treated == "true" then
                        labelText = labelText .. " (Treated)"
                    else
                        labelText = labelText .. " (Room: " .. tostring(room) .. ")"
                    end

                    local hl = Instance.new("Highlight")
                    hl.Name = "Shellae_NpcESP"
                    hl.FillColor = color
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0.1
                    hl.Adornee = npc
                    hl.Parent = npc
                    table.insert(Highlights, hl)

                    local bill = Instance.new("BillboardGui")
                    bill.Name = "Shellae_Billboard"
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

-- Refresh ESP loop when toggled on
task.spawn(function()
    while task.wait(3) do
        if ScriptActive and (Toggles.RoomESP or Toggles.NpcESP) then
            pcall(updateESP)
        end
    end
end)
print("ESP functions defined.")

-- ============ MAIN TAB ============

-- ---- Feature 1: Auto Heartbeat ----
local heartbeatConnection = nil

local function setupHeartbeatListener()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end

    if not Toggles.AutoHeartbeat then return end

    -- Safe retrieval using pcall and checks instead of script breaking loops
    task.spawn(function()
        local reFolder = Net:FindFirstChild("RE")
        if not reFolder then return end
        
        local heartbeatEvent = reFolder:FindFirstChild("StartHeartbeatMinigame")
        local completeEvent = reFolder:FindFirstChild("HeartbeatMinigameComplete")

        if heartbeatEvent and completeEvent then
            heartbeatConnection = heartbeatEvent.OnClientEvent:Connect(function()
                if Toggles.AutoHeartbeat and ScriptActive then
                    task.wait(0.2)
                    completeEvent:FireServer(true, true)
                end
            end)
        end
    end)
end

MainTab:CreateToggle({
    Name = "Auto Heartbeat Minigame",
    CurrentValue = false,
    Flag = "AutoHeartbeat",
    Callback = function(Value)
        Toggles.AutoHeartbeat = Value
        setupHeartbeatListener()
    end
})

-- ---- Feature 2: Instant Proximity ----
local promptConnection = nil

local function restorePrompts()
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local original = prompt:GetAttribute("OriginalHoldDuration")
            if original then
                prompt.HoldDuration = original
            end
        end
    end
end

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

local function setupPromptListener()
    if promptConnection then
        promptConnection:Disconnect()
        promptConnection = nil
    end

    if not Toggles.InstantPrompt then
        restorePrompts()
        return
    end

    promptConnection = ProximityPromptService.PromptShown:Connect(function(prompt)
        if Toggles.InstantPrompt and ScriptActive then
            if not prompt:GetAttribute("OriginalHoldDuration") then
                prompt:SetAttribute("OriginalHoldDuration", prompt.HoldDuration)
            end
            prompt.HoldDuration = 0
        end
    end)

    updatePromptsState(true)
end

MainTab:CreateToggle({
    Name = "Instant Proximity",
    CurrentValue = false,
    Flag = "InstantPrompt",
    Callback = function(Value)
        Toggles.InstantPrompt = Value
        setupPromptListener()
    end
})

-- ---- Feature 3: ESP Toggles ----
MainTab:CreateToggle({
    Name = "Room ESP",
    CurrentValue = false,
    Flag = "RoomESP",
    Callback = function(Value)
        Toggles.RoomESP = Value
        if not Value then clearESP() else updateESP() end
    end
})

MainTab:CreateToggle({
    Name = "NPC ESP",
    CurrentValue = false,
    Flag = "NpcESP",
    Callback = function(Value)
        Toggles.NpcESP = Value
        if not Value then clearESP() else updateESP() end
    end
})

-- ---- Feature 4: Infinite Sanity ----
local sanityConnection = nil

local function setupSanity()
    if sanityConnection then
        sanityConnection:Disconnect()
        sanityConnection = nil
    end

    if not Toggles.InfSanity then return end

    if LocalPlayer then
        pcall(function()
            if LocalPlayer:GetAttribute("Sanity") then
                LocalPlayer:SetAttribute("Sanity", 100)
            end
        end)

        sanityConnection = LocalPlayer:GetAttributeChangedSignal("Sanity"):Connect(function()
            if Toggles.InfSanity and ScriptActive then
                local currentSanity = LocalPlayer:GetAttribute("Sanity")
                if currentSanity and currentSanity < 100 then
                    LocalPlayer:SetAttribute("Sanity", 100)
                end
            end
        end)
    end
end

MainTab:CreateToggle({
    Name = "Infinite Sanity",
    CurrentValue = false,
    Flag = "InfSanity",
    Callback = function(Value)
        Toggles.InfSanity = Value
        setupSanity()
        Rayfield:Notify({
            Title = "Infinite Sanity",
            Content = Value and "Sanity locked at 100" or "Disabled",
            Duration = 2
        })
    end
})

-- ============ VISUAL TAB ============
local anomalyExecuted = false

VisualTab:CreateButton({
    Name = "Enable Anomaly Highlights",
    Callback = function()
        if anomalyExecuted then
            Rayfield:Notify({
                Title = "Already Running",
                Content = "Anomaly sensor is already active.",
                Duration = 2
            })
            return
        end

        local function applyHighlight(v)
            if not v:IsA("Model") then return end
            local h = Instance.new("Highlight")
            -- Fixed Color3 setup from .new to .fromRGB
            if v:GetAttribute("HasCameraEffect") or v:GetAttribute("Skinwalker") or v:GetAttribute("CameraEffect") then
                h.FillColor = Color3.fromRGB(255, 0, 0)
            else
                h.FillColor = Color3.fromRGB(0, 255, 0)
            end
            h.Parent = v
            h.Adornee = v
        end

        local function startAnomalySensor()
            local npcsFolder = workspace:FindFirstChild("NPCs")
            if not npcsFolder then 
                warn("NPCs folder not found in workspace yet.")
                return 
            end

            for _, v in ipairs(npcsFolder:GetChildren()) do
                pcall(applyHighlight, v)
            end

            npcsFolder.ChildAdded:Connect(function(instance)
                task.wait(0.1) -- give attributes time to replicate
                pcall(applyHighlight, instance)
            end)
        end

        pcall(startAnomalySensor)
        anomalyExecuted = true

        Rayfield:Notify({
            Title = "Anomaly Sensor",
            Content = "Highlights activated! Red = threat, Green = safe.",
            Duration = 3
        })
    end
})

-- ============ STARTUP NOTIFICATION ============
Rayfield:Notify({
    Title = "XDHub Loaded",
    Content = "Main: Heartbeat, Prompt, ESP, Sanity | Visual: Highlights",
    Duration = 3
})

print("XDHub - Animal Hospital script execution finished.")
