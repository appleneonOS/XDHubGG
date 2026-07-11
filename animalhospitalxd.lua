-- Wrap inside a protected call to load the Rayfield UI Library safely
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success or not Rayfield then return end

-- Create main UI Window
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
    Discord = {
        Enabled = false
    }
})

-- UI Tabs
local MainTab = Window:CreateTab("Main", nil)
local VisualTab = Window:CreateTab("Visual", nil)

-- Services & Local Player
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Script States & Configuration
local ScriptActive = true
local Toggles = {
    AutoHeartbeat = false,
    AutoProcess = false,
    AutoTreat = false,
    AutoTrash = false,
    CoffeeAura = false,
    DoorAura = false,
    RoomESP = false,
    NpcESP = false,
    InfSanity = false
}

local ActiveHighlights = {}
local ActiveBillboards = {}

-- Connections
local HeartbeatConnection = nil
local ProcessConnection = nil
local TrashConnection = nil
local CoffeeConnection = nil
local DoorConnection = nil
local SanityConnection = nil

-- Filter Strings for Proximity Prompts
local ProcessKeywords = {"Stamp Forms", "Form", "Take Photo", "Register", "Badge", "Take", "Talk"}

-- Helper: Check if an entity is an Anomaly
local function isAnomaly(npc)
    if not npc then return false end
    
    if npc:GetAttribute("Fake") == true or npc:GetAttribute("Fake") == "true" then return true end
    if npc:GetAttribute("Skinwalker") == true or npc:GetAttribute("Skinwalker") == "true" then return true end
    
    if CollectionService:HasTag(npc, "Skinwalker") or 
       CollectionService:HasTag(npc, "SkinwalkerMonster") or 
       CollectionService:HasTag(npc, "GhostAnomaly") then 
        return true 
    end
    
    local nameLower = npc.Name:lower()
    if nameLower:find("monster") or nameLower:find("ghost") or nameLower:find("anomaly") then 
        return true 
    end
    
    return false
end

-- Helper: Check if an entity is a Patient
local function isPatient(npc)
    if not npc then return false end
    if npc:GetAttribute("IsPatient") == true or npc:GetAttribute("IsPatient") == "true" then return true end
    if CollectionService:HasTag(npc, "ActivePatient") then return true end
    return false
end

-- Clear Visuals (ESP elements)
local function clearESP()
    for _, visual in ipairs(ActiveHighlights) do
        if visual and visual.Parent then pcall(function() visual:Destroy() end) end
    end
    for _, visual in ipairs(ActiveBillboards) do
        if visual and visual.Parent then pcall(function() visual:Destroy() end) end
    end
    ActiveHighlights = {}
    ActiveBillboards = {}
end

-- Render Room and NPC ESP
local function updateESP()
    clearESP()
    if not ScriptActive then return end
    
    -- Room ESP Section
    if Toggles.RoomESP then
        local rooms = workspace:FindFirstChild("Rooms")
        local medical = rooms and rooms:FindFirstChild("Medical")
        if medical then
            for _, room in ipairs(medical:GetChildren()) do
                local minigame = room:FindFirstChild("Minigame")
                if minigame then
                    for _, object in ipairs(minigame:GetChildren()) do
                        if object:IsA("Model") and (object.Name == "Monitor" or object.Name == "Bed" or object.Name == "Analyzer") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "Shellae_RoomESP"
                            highlight.FillColor = Color3.fromRGB(0, 180, 255)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.6
                            highlight.OutlineTransparency = 0.2
                            highlight.Adornee = object
                            highlight.Parent = object
                            table.insert(ActiveHighlights, highlight)
                        end
                    end
                end
            end
        end
    end
    
    -- NPC ESP Section
    if Toggles.NpcESP then
        local npcsFolder = workspace:FindFirstChild("NPCs")
        if npcsFolder then
            for _, npc in ipairs(npcsFolder:GetChildren()) do
                if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                    local flagAnomaly = isAnomaly(npc)
                    local flagPatient = isPatient(npc)
                    local roomName = npc:GetAttribute("DesignatedRoom") or "Lobby"
                    local isCured = npc:GetAttribute("Treated") or npc:GetAttribute("IsCured")
                    
                    local fillHex = nil
                    local labelText = ""
                    
                    if flagAnomaly then
                        fillHex = Color3.fromRGB(255, 30, 30)
                        labelText = "⚠️ [ANOMALY] " .. npc.Name
                    elseif flagPatient then
                        fillHex = Color3.fromRGB(0, 255, 127)
                        labelText = "[Patient] " .. npc.Name
                    end
                    
                    if fillHex then
                        if isCured == true or isCured == "true" then
                            labelText = labelText .. " (Treated)"
                        else
                            labelText = labelText .. " (Room: " .. tostring(roomName) .. ")"
                        end
                        
                        -- ESP Outline
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "Shellae_NpcESP"
                        highlight.FillColor = fillHex
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.4
                        highlight.OutlineTransparency = 0.1
                        highlight.Adornee = npc
                        highlight.Parent = npc
                        table.insert(ActiveHighlights, highlight)
                        
                        -- Overhead Name tag
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "Shellae_Billboard"
                        billboard.Adornee = npc:FindFirstChild("Head") or npc.HumanoidRootPart
                        billboard.Size = UDim2.new(0, 200, 0, 50)
                        billboard.AlwaysOnTop = true
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = labelText
                        label.TextColor3 = fillHex
                        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        label.TextStrokeTransparency = 0
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 12
                        label.Parent = billboard
                        
                        billboard.Parent = npc.HumanoidRootPart
                        table.insert(ActiveBillboards, billboard)
                    end
                end
            end
        end
    end
end

-- Refresh ESP Loop
task.spawn(function()
    while task.wait(3) do
        if ScriptActive and (Toggles.RoomESP or Toggles.NpcESP) then
            pcall(updateESP)
        end
    end
end)

-- Feature: Auto Heartbeat Minigame
local function setupAutoHeartbeat()
    if HeartbeatConnection then HeartbeatConnection:Disconnect() HeartbeatConnection = nil end
    if not Toggles.AutoHeartbeat then return end
    
    task.spawn(function()
        local re = ReplicatedStorage:WaitForChild("RE", 5)
        if not re then return end
        local startEvent = re:WaitForChild("StartHeartbeatMinigame", 5)
        local completeEvent = re:WaitForChild("HeartbeatMinigameComplete", 5)
        
        if startEvent and completeEvent then
            HeartbeatConnection = startEvent.OnClientEvent:Connect(function()
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
    Callback = function(value)
        Toggles.AutoHeartbeat = value
        setupAutoHeartbeat()
    end
})

-- Feature: Auto Process
local function shouldAutoProcess(prompt)
    local nameLower = prompt.Name:lower()
    local parentLower = prompt.Parent and prompt.Parent.Name:lower() or ""
    for _, keyword in ipairs(ProcessKeywords) do
        if nameLower:find(keyword:lower()) or parentLower:find(keyword:lower()) then
            return true
        end
    end
    return false
end

local function setupAutoProcess()
    if ProcessConnection then ProcessConnection:Disconnect() ProcessConnection = nil end
    if not Toggles.AutoProcess then return end
    
    -- Optimized: Event listener triggers only when prompts appear nearby
    ProcessConnection = ProximityPromptService.PromptShown:Connect(function(prompt)
        if not Toggles.AutoProcess or not ScriptActive then return end
        if shouldAutoProcess(prompt) then
            prompt.MaxActivationDistance = 50
            prompt.HoldDuration = 0
            fireproximityprompt(prompt)
        end
    end)
end

MainTab:CreateToggle({
    Name = "Auto Process (Stamp, Photo, Register, etc.)",
    CurrentValue = false,
    Flag = "AutoProcess",
    Callback = function(value)
        Toggles.AutoProcess = value
        setupAutoProcess()
        Rayfield:Notify({
            Title = "Auto Process",
            Content = value and "Enabled" or "Disabled",
            Duration = 2
        })
    end
})

-- Feature: Auto Treat (Full Sequence)
local function getTvScreenText()
    if not LocalPlayer then return nil end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local tvScreen = playerGui:FindFirstChild("TVScreen")
        if tvScreen then
            local medicineText = tvScreen:FindFirstChild("MedicineText")
            if medicineText and medicineText:IsA("TextLabel") then
                return medicineText.Text
            end
        end
    end
    
    -- Fallback map scan for TV SurfaceGuis
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("SurfaceGui") and object.Name:find("TV") then
            for _, child in ipairs(object:GetChildren()) do
                if child:IsA("TextLabel") then
                    return child.Text
                end
            end
        end
    end
    return nil
end

local function applyMedicine(medicineName)
    print("Applying medicine:", medicineName)
end

local function triggerPromptByName(targetName)
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") and object.Name:find(targetName) then
            fireproximityprompt(object)
            return true
        end
    end
    return false
end

local function runTreatSequence()
    if not Toggles.AutoTreat or not ScriptActive then return end
    
    local step1 = triggerPromptByName("DNA") or triggerPromptByName("Sampler")
    task.wait(0.5)
    local step2 = triggerPromptByName("Analyzer") or triggerPromptByName("Analyze")
    task.wait(0.5)
    local step3 = triggerPromptByName("Process") or triggerPromptByName("Result")
    task.wait(0.5)
    
    local diagnosisText = getTvScreenText()
    if diagnosisText then
        applyMedicine(diagnosisText)
    end
end

task.spawn(function()
    while task.wait(1) do
        if Toggles.AutoTreat and ScriptActive then
            pcall(runTreatSequence)
        end
    end
end)

MainTab:CreateToggle({
    Name = "Auto Treat (Full Sequence)",
    CurrentValue = false,
    Flag = "AutoTreat",
    Callback = function(value)
        Toggles.AutoTreat = value
        Rayfield:Notify({
            Title = "Auto Treat",
            Content = value and "Enabled" or "Disabled",
            Duration = 2
        })
    end
})

-- Feature: Auto Trash
local function setupAutoTrash()
    if TrashConnection then TrashConnection:Disconnect() TrashConnection = nil end
    if not Toggles.AutoTrash then return end
    
    TrashConnection = ProximityPromptService.PromptShown:Connect(function(prompt)
        if not Toggles.AutoTrash or not ScriptActive then return end
        if prompt.Name:lower():find("trash") or (prompt.Parent and prompt.Parent.Name:lower():find("trash")) then
            prompt.MaxActivationDistance = 50
            prompt.HoldDuration = 0
            fireproximityprompt(prompt)
        end
    end)
end

MainTab:CreateToggle({
    Name = "Auto Trash",
    CurrentValue = false,
    Flag = "AutoTrash",
    Callback = function(value)
        Toggles.AutoTrash = value
        setupAutoTrash()
        Rayfield:Notify({
            Title = "Auto Trash",
            Content = value and "Enabled" or "Disabled",
            Duration = 2
        })
    end
})

-- Feature: Coffee Aura
local function drinkCoffee()
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") and (object.Name:lower():find("coffee") or (object.Parent and object.Parent.Name:lower():find("coffee"))) then
            fireproximityprompt(object)
            return true
        end
    end
    return false
end

local function setupCoffeeAura()
    if CoffeeConnection then CoffeeConnection:Disconnect() CoffeeConnection = nil end
    if not Toggles.CoffeeAura then return end
    
    CoffeeConnection = LocalPlayer:GetAttributeChangedSignal("Sanity"):Connect(function()
        if Toggles.CoffeeAura and ScriptActive then
            local currentSanity = LocalPlayer:GetAttribute("Sanity")
            if currentSanity and currentSanity < 80 then
                drinkCoffee()
            end
        end
    end)
end

task.spawn(function()
    while task.wait(1.5) do
        if Toggles.CoffeeAura and ScriptActive then
            drinkCoffee()
        end
    end
end)

MainTab:CreateToggle({
    Name = "Coffee Aura (Auto Drink)",
    CurrentValue = false,
    Flag = "CoffeeAura",
    Callback = function(value)
        Toggles.CoffeeAura = value
        setupCoffeeAura()
        Rayfield:Notify({
            Title = "Coffee Aura",
            Content = value and "Enabled" or "Disabled",
            Duration = 2
        })
    end
})

-- Feature: Door Aura
local function isDoorPrompt(prompt)
    local nameLower = prompt.Name:lower()
    local parentLower = prompt.Parent and prompt.Parent.Name:lower() or ""
    if nameLower:find("door") or nameLower:find("open") or nameLower:find("close") or nameLower:find("entry") or nameLower:find("exit") then
        return true
    end
    if parentLower:find("door") or parentLower:find("entrance") or parentLower:find("exit") then
        return true
    end
    return false
end

local function setupDoorAura()
    if DoorConnection then DoorConnection:Disconnect() DoorConnection = nil end
    if not Toggles.DoorAura then return end
    
    -- Optimized: Event listener opens doors instantly when stepping within proximity range
    DoorConnection = ProximityPromptService.PromptShown:Connect(function(prompt)
        if not Toggles.DoorAura or not ScriptActive then return end
        if isDoorPrompt(prompt) then
            prompt.MaxActivationDistance = 50
            prompt.HoldDuration = 0
            fireproximityprompt(prompt)
        end
    end)
end

MainTab:CreateToggle({
    Name = "Door Aura (Auto Open)",
    CurrentValue = false,
    Flag = "DoorAura",
    Callback = function(value)
        Toggles.DoorAura = value
        setupDoorAura()
        Rayfield:Notify({
            Title = "Door Aura",
            Content = value and "Enabled — doors will open automatically" or "Disabled",
            Duration = 2
        })
    end
})

-- Feature: Infinite Sanity
local function setupInfiniteSanity()
    if SanityConnection then SanityConnection:Disconnect() SanityConnection = nil end
    if not Toggles.InfSanity then return end
    
    if LocalPlayer then
        pcall(function()
            if LocalPlayer:GetAttribute("Sanity") then
                LocalPlayer:SetAttribute("Sanity", 100)
            end
        end)
        SanityConnection = LocalPlayer:GetAttributeChangedSignal("Sanity"):Connect(function()
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
    Callback = function(value)
        Toggles.InfSanity = value
        setupInfiniteSanity()
    end
})

-- ESP Toggles
MainTab:CreateToggle({
    Name = "Room ESP",
    CurrentValue = false,
    Flag = "RoomESP",
    Callback = function(value)
        Toggles.RoomESP = value
        if not value then clearESP() else updateESP() end
    end
})

MainTab:CreateToggle({
    Name = "NPC ESP",
    CurrentValue = false,
    Flag = "NpcESP",
    Callback = function(value)
        Toggles.NpcESP = value
        if not value then clearESP() else updateESP() end
    end
})

-- Feature: Static Anomaly Highlights (Visuals Tab Button)
local anomalySensorActive = false
VisualTab:CreateButton({
    Name = "Enable Anomaly Highlights",
    Callback = function()
        if anomalySensorActive then
            Rayfield:Notify({
                Title = "Already Running",
                Content = "Anomaly sensor is already active.",
                Duration = 2
            })
            return
        end
        
        local function applyHighlight(model)
            if not model:IsA("Model") then return end
            local highlight = Instance.new("Highlight")
            
            if model:GetAttribute("HasCameraEffect") or model:GetAttribute("Skinwalker") or model:GetAttribute("CameraEffect") then
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red threat
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Green safe
            end
            highlight.Parent = model
            highlight.Adornee = model
        end
        
        local function initSensor()
            local npcsFolder = workspace:FindFirstChild("NPCs")
            if not npcsFolder then return end
            
            for _, npc in ipairs(npcsFolder:GetChildren()) do
                pcall(applyHighlight, npc)
            end
            
            npcsFolder.ChildAdded:Connect(function(newNpc)
                task.wait(0.1)
                pcall(applyHighlight, newNpc)
            end)
        end
        
        pcall(initSensor)
        anomalySensorActive = true
        Rayfield:Notify({
            Title = "Anomaly Sensor",
            Content = "Highlights activated! Red = threat, Green = safe.",
            Duration = 3
        })
    end
})

-- Initialization Notification
Rayfield:Notify({
    Title = "XDHub Loaded",
    Content = "All toggles ready. Optimized event loops integrated!",
    Duration = 3
