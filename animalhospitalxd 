-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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

-- ============ TABS ============
local MainTab = Window:CreateTab("Main", nil)
local VisualTab = Window:CreateTab("Visual", nil)

-- ============ SERVICES ============
local Net = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

-- ============ HELPER FUNCTIONS ============

-- Check if NPC is an Anomaly
local function isNpcAnomaly(npc)
    local isFake = npc:GetAttribute("Fake")
    if isFake == true or isFake == "true" then
        return true
    end

    local isSkinwalker = npc:GetAttribute("Skinwalker")
    if isSkinwalker == true or isSkinwalker == "true" then
        return true
    end

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

-- ============ ESP FUNCTIONS ============

local function clearESP()
    for _, obj in ipairs(Highlights) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    for _, obj in ipairs(BillboardGuis) do
        if obj and obj.Parent then
            obj:Destroy()
        end
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
                        color = Color3.fromRGB(255, 30, 30) -- Red for Anomaly
                        labelText = "⚠️ [ANOMALY] " .. npc.Name
                    elseif isPatient then
                        color = Color3.fromRGB(0, 255, 127) -- Green for Real
                        labelText = "[Patient] " .. npc.Name
                    else
                        -- Not a patient and not a known anomaly – skip
                        goto continue
                    end

                    if treated == true or treated == "true" then
                        labelText = labelText .. " (Treated)"
                    else
                        labelText = labelText .. " (Room: " .. tostring(room) .. ")"
                    end

                    -- Highlight Model
                    local hl = Instance.new("Highlight")
                    hl.Name = "Shellae_NpcESP"
                    hl.FillColor = color
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0.1
                    hl.Adornee = npc
                    hl.Parent = npc
                    table.insert(Highlights, hl)

                    -- Overhead Label
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

                    ::continue::
                end
            end
        end
    end
end

-- ============ MAIN TAB ============

-- ---- Feature 1: Auto Heartbeat ----
local heartbeatConnection = nil

local function setupHeartbeatListener()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end

    if not Toggles.AutoHeartbeat then
        return
    end

    pcall(function()
        local heartbeatEvent = Net:WaitForChild("RE/StartHeartbeatMinigame")
        local completeEvent = Net:WaitForChild("RE/HeartbeatMinigameComplete")

        heartbeatConnection = heartbeatEvent.OnClientEvent:Connect(function()
            if Toggles.AutoHeartbeat and ScriptActive then
                task.wait(0.2)
                completeEvent:FireServer(true, true)
            end
        end)
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

-- ---- Feature 3: ESP ----
MainTab:CreateToggle({
    Name = "Room ESP",
    CurrentValue = false,
    Flag = "RoomESP",
    Callback = function(Value)
        Toggles.RoomESP = Value
        updateESP()
    end
})

MainTab:CreateToggle({
    Name = "NPC ESP",
    CurrentValue = false,
    Flag = "NpcESP",
    Callback = function(Value)
        Toggles.NpcESP = Value
        updateESP()
    end
})

-- ---- Feature 4: Infinite Sanity ----
local sanityConnection = nil

local function setupSanity()
    if sanityConnection then
        sanityConnection:Disconnect()
        sanityConnection = nil
    end

    if not Toggles.InfSanity then
        -- Optionally, we could restore the sanity to its original value, but we'll leave it as is.
        return
    end

    -- Set sanity to 100 immediately
    if LocalPlayer and LocalPlayer:GetAttribute("Sanity") then
        LocalPlayer:SetAttribute("Sanity", 100)
    end

    -- Connect to the Sanity attribute change
    sanityConnection = LocalPlayer:GetAttributeChangedSignal("Sanity"):Connect(function()
        if Toggles.InfSanity and ScriptActive then
            local currentSanity = LocalPlayer:GetAttribute("Sanity")
            if currentSanity and currentSanity < 100 then
                LocalPlayer:SetAttribute("Sanity", 100)
            end
        end
    end)
end

MainTab:CreateToggle({
    Name = "Infinite Sanity",
    CurrentValue = false,
    Flag = "InfSanity",
    Callback = function(Value)
        Toggles.InfSanity = Value
        setupSanity()
        if Value then
            Rayfield:Notify({
                Title = "Infinite Sanity",
                Content = "Sanity locked at 100",
                Duration = 2
            })
        else
            Rayfield:Notify({
                Title = "Infinite Sanity",
                Content = "Disabled",
                Duration = 2
            })
        end
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

        local function startAnomalySensor()
            local npcs = workspace.NPCs:GetChildren()
            for i, v in ipairs(npcs) do
                local h = Instance.new("Highlight")
                if v:GetAttribute("HasCameraEffect") or v:GetAttribute("Skinwalker") or v:GetAttribute("CameraEffect") then
                    h.FillColor = Color3.new(255, 0, 0)
                else
                    h.FillColor = Color3.new(0, 255, 0)
                end
                h.Parent = v
                h.Adornee = v
            end

            workspace.NPCs.ChildAdded:Connect(function(instance)
                local h = Instance.new("Highlight")
                if instance:GetAttribute("HasCameraEffect") or instance:GetAttribute("Skinwalker") or instance:GetAttribute("CameraEffect") then
                    h.FillColor = Color3.new(255, 0, 0)
                else
                    h.FillColor = Color3.new(0, 255, 0)
                end
                h.Parent = instance
                h.Adornee = instance
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