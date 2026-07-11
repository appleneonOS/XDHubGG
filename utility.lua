-- ==========================================
-- UTILITY – ANIMAL HOSPITAL SERVICES
-- All backend functions, config, and loops.
-- ==========================================

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")

-- ==========================================
-- CONFIGURATION (exposed to Main)
-- ==========================================
local Config = {
    InstantAction = false,
    InfiniteSanity = false,
    ESPAnomaly = false,
    ESPPatient = false,
    ESPVisitor = false,
    AutoRoom6 = false,
    AutoRoom7 = false,
    AutoRoom8 = false,
    AutoProcess = false,
    AutoFarm = false,
    AutoReject = false,
    AutoCheckIn = false,
    AutoBarneyCoffee = false,
    AutoTreat = false,
    NoClip = false,
    FarmDelay = 1.5,
    WalkSpeed = 16,
}

-- Make Config globally accessible for Main
getgenv().UtilityConfig = Config

-- ==========================================
-- ITEM CACHE
-- ==========================================
local ItemPromptCache = {}
local CacheRefreshTime = 0
local CACHE_DURATION = 3

local function RefreshItemCache()
    ItemPromptCache = {}
    CacheRefreshTime = os.clock()
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Enabled and desc.ActionText then
            ItemPromptCache[string.lower(desc.ActionText)] = desc
        end
    end
end

local function GetCachedItemPrompt(itemName)
    if not itemName or itemName == "" then return nil end
    if os.clock() - CacheRefreshTime > CACHE_DURATION then RefreshItemCache() end
    local target = string.lower(itemName)
    for key, prompt in pairs(ItemPromptCache) do
        if string.find(key, target) or string.find(target, key) then return prompt end
    end
    return nil
end

-- ==========================================
-- CORE UTILITY FUNCTIONS
-- ==========================================
local function GetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function FindBasePartInObject(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("BasePart") then return child end
        if child:IsA("Model") then
            local part = FindBasePartInObject(child)
            if part then return part end
        end
    end
    return nil
end

local function SafeTeleport(position)
    local root = GetRootPart()
    if not root then return end
    local newPos = position + Vector3.new(0, 2, 0)
    local success, err = pcall(function()
        root.CFrame = CFrame.new(newPos)
    end)
    if success then
        RunService.Heartbeat:Wait()
        root.Velocity = Vector3.new(0, 0, 0)
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
    end
end

local function LookAtPosition(targetPosition)
    local root = GetRootPart()
    if root and targetPosition then
        pcall(function()
            root.CFrame = CFrame.lookAt(root.Position, targetPosition)
            local character = GetCharacter()
            if character then
                local head = character:FindFirstChild("Head")
                if head then
                    local camPos = head.Position - (root.CFrame.LookVector * 4) + Vector3.new(0, 2, 0)
                    Camera.CFrame = CFrame.lookAt(camPos, targetPosition)
                end
            end
        end)
    end
end

local function FirePromptDirect(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
    local targetPart = FindBasePartInObject(prompt.Parent)
    if targetPart then LookAtPosition(targetPart.Position) end
    if Config.InstantAction then prompt.HoldDuration = 0 end
    local success = false
    local s1, e1 = pcall(function() fireproximityprompt(prompt) end)
    if s1 then success = true end
    if not success then
        local s2, e2 = pcall(function()
            prompt:InputHoldStart(player)
            task.wait(0.05)
            prompt:InputHoldEnd(player)
        end)
        if s2 then success = true end
    end
    if not success then
        local s3, e3 = pcall(function()
            local mouse = player:GetMouse()
            if mouse then
                local part = FindBasePartInObject(prompt.Parent)
                if part then
                    mouse.Target = part
                    mouse.TargetClick:Fire()
                end
            end
        end)
        if s3 then success = true end
    end
    return success
end

local function FirePromptWithCamera(prompt, targetPosition)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    if targetPosition then LookAtPosition(targetPosition) end
    return FirePromptDirect(prompt)
end

local function ClickButton(buttonPart)
    if not buttonPart then return false end
    local clickDetector = buttonPart:FindFirstChildOfClass("ClickDetector")
    if clickDetector then
        LookAtPosition(buttonPart.Position)
        local success, err = pcall(function() fireclickdetector(clickDetector) end)
        if success then return true end
    end
    return false
end

-- ==========================================
-- INFINITE SANITY
-- ==========================================
local sanityConnections = {}
local function keepSanityFull()
    if not Config.InfiniteSanity then return end
    pcall(function()
        player:SetAttribute("Sanity", 999)
        local Library = ReplicatedStorage:FindFirstChild("Lib")
        if Library then
            local lib = require(Library)
            if type(lib.Inject) == "function" then
                lib.Inject("PlayerLostSanity", function()
                    player:SetAttribute("Sanity", 999)
                end)
            end
        end
    end)
end

local function startInfiniteSanity()
    for _, conn in ipairs(sanityConnections) do
        pcall(function() conn:Disconnect() end)
    end
    sanityConnections = {}
    local conn1 = player:GetAttributeChangedSignal("Sanity"):Connect(function()
        keepSanityFull()
    end)
    table.insert(sanityConnections, conn1)
    local conn2 = RunService.Heartbeat:Connect(function()
        keepSanityFull()
    end)
    table.insert(sanityConnections, conn2)
    keepSanityFull()
end

local function stopInfiniteSanity()
    for _, conn in ipairs(sanityConnections) do
        pcall(function() conn:Disconnect() end)
    end
    sanityConnections = {}
end

-- Monitor toggle changes
task.spawn(function()
    local lastState = false
    while true do
        local current = Config.InfiniteSanity
        if current and not lastState then
            startInfiniteSanity()
        elseif not current and lastState then
            stopInfiniteSanity()
        end
        lastState = current
        task.wait(0.5)
    end
end)

-- ==========================================
-- ESP FUNCTIONS
-- ==========================================
local NPC_FOLDER = "NPCs"
local ANOMALY_NAME = "Skinwalker"
local PATIENT_ATTR = "IsPatient"
local VISITOR_ATTR = "IsVisitor"
local IGNORED_FLAGS = {
    StoryForced = true,
    AlwaysPatient = true
}
local highlights = {}

local function getNPCFolder()
    return Workspace:FindFirstChild(NPC_FOLDER)
end

local function modelHasParts(model)
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") then return true end
    end
    return false
end

local function getDataValue(model, name)
    local attr = model:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = model:FindFirstChild(name)
    if child and child:IsA("ValueBase") then return child.Value end
    return nil
end

local function hasData(model, name)
    if model:GetAttribute(name) ~= nil then return true end
    if model:FindFirstChild(name) then return true end
    return false
end

local function isForcedIgnored(model)
    for flagName in pairs(IGNORED_FLAGS) do
        if hasData(model, flagName) then return true end
    end
    return false
end

local function isPatient(model)
    return getDataValue(model, PATIENT_ATTR) == true
end

local function isVisitor(model)
    return typeof(getDataValue(model, VISITOR_ATTR)) == "number"
end

local function isAnomaly(model)
    return model.Name == ANOMALY_NAME
end

local function shouldScan(model)
    if isForcedIgnored(model) then return false end
    return isPatient(model) or isVisitor(model) or isAnomaly(model)
end

local function removeHighlight(model)
    local hl = highlights[model]
    if hl then hl:Destroy() end
    highlights[model] = nil
end

local function getHighlight(model)
    if highlights[model] and highlights[model].Parent then
        return highlights[model]
    end
    local hl = Instance.new("Highlight")
    hl.Name = "AnimalHospitalESP"
    hl.Adornee = model
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0
    hl.Parent = model
    highlights[model] = hl
    return hl
end

local function setHighlight(model, highlightType)
    local hl = getHighlight(model)
    if highlightType == "anomaly" then
        hl.FillColor = Color3.fromRGB(255, 45, 65)
        hl.OutlineColor = Color3.fromRGB(255, 0, 25)
    elseif highlightType == "patient" then
        hl.FillColor = Color3.fromRGB(55, 255, 120)
        hl.OutlineColor = Color3.fromRGB(0, 255, 90)
    elseif highlightType == "visitor" then
        hl.FillColor = Color3.fromRGB(100, 200, 255)
        hl.OutlineColor = Color3.fromRGB(50, 150, 255)
    end
end

local function cleanup(npcFolder, forceClear)
    for model, hl in pairs(highlights) do
        if forceClear or not model.Parent or not npcFolder or not model:IsDescendantOf(npcFolder) or not shouldScan(model) then
            if hl then hl:Destroy() end
            highlights[model] = nil
        end
    end
end

local function updateESP()
    local npcFolder = getNPCFolder()
    if not npcFolder then return end
    cleanup(npcFolder, false)
    for _, model in ipairs(npcFolder:GetChildren()) do
        if model:IsA("Model") and modelHasParts(model) and shouldScan(model) then
            local highlightType = nil
            if isAnomaly(model) then
                if Config.ESPAnomaly then highlightType = "anomaly" end
            elseif isPatient(model) then
                if Config.ESPPatient then highlightType = "patient" end
            elseif isVisitor(model) then
                if Config.ESPVisitor then highlightType = "visitor" end
            end
            if highlightType then
                setHighlight(model, highlightType)
            else
                removeHighlight(model)
            end
        end
    end
end

local function clearESP()
    for model, hl in pairs(highlights) do
        hl:Destroy()
    end
    highlights = {}
end

-- ESP update loop
task.spawn(function()
    while true do
        updateESP()
        task.wait(1.5)
    end
end)

-- ==========================================
-- PATIENT & ANOMALY FINDERS
-- ==========================================
local function findPatients()
    local patients = {}
    local npcFolder = getNPCFolder()
    if not npcFolder then return patients end
    for _, model in ipairs(npcFolder:GetChildren()) do
        if model:IsA("Model") and isPatient(model) then
            table.insert(patients, model)
        end
    end
    return patients
end

local function findAnomalies()
    local anomalies = {}
    local npcFolder = getNPCFolder()
    if not npcFolder then return anomalies end
    for _, model in ipairs(npcFolder:GetChildren()) do
        if model:IsA("Model") and isAnomaly(model) then
            table.insert(anomalies, model)
        end
    end
    return anomalies
end

-- ==========================================
-- HEAL & REJECT
-- ==========================================
local function healPatient(patient)
    for _, desc in ipairs(patient:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Enabled then
            local action = desc.ActionText or ""
            if string.find(string.lower(action), "treat") or string.find(string.lower(action), "heal") then
                return FirePromptWithCamera(desc, patient:GetPivot().Position)
            end
        end
        if desc:IsA("ClickDetector") then
            return ClickButton(desc.Parent)
        end
    end
    return false
end

local function rejectAnomaly()
    local shutters = Workspace:FindFirstChild("Shutters")
    if shutters then
        for _, desc in ipairs(shutters:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then
                return FirePromptWithCamera(desc, shutters.Position)
            end
            if desc:IsA("ClickDetector") then
                return ClickButton(desc.Parent)
            end
        end
    end
    return false
end

-- ==========================================
-- ROOM 6 HELPERS & LOGIC
-- ==========================================
local function GetEmergencyRooms()
    return Workspace:FindFirstChild("EmergencyRooms") or Workspace:FindFirstChild("Emergency")
end

local function FindXrayMonitorInMinigame(room6)
    if not room6 then return nil end
    for _, obj in ipairs(room6:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "xray") or string.find(string.lower(obj.Name), "x-ray")) then
            return obj.Parent
        end
        if obj:IsA("ProximityPrompt") and obj.ActionText and string.find(string.lower(obj.ActionText), "x-ray") then
            return obj.Parent
        end
    end
    return nil
end

local function FindColorsInMinigame(room6)
    if not room6 then return nil end
    local minigame = room6:FindFirstChild("Minigame") or room6
    return minigame:FindFirstChild("Colors") or minigame:FindFirstChild("Buttons")
end

local function GetButtonModels(colorsFolder)
    if not colorsFolder then return {} end
    local buttons = {}
    for _, model in ipairs(colorsFolder:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("Button") then
            local btn = model:FindFirstChild("Button")
            if btn and btn:IsA("BasePart") then
                table.insert(buttons, btn)
            end
        end
    end
    return buttons
end

local function GetButtonColors(colorsFolder)
    if not colorsFolder then return {} end
    local colors = {}
    for _, model in ipairs(colorsFolder:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("Button") then
            local btn = model:FindFirstChild("Button")
            if btn and btn:IsA("BasePart") then
                table.insert(colors, btn.Color)
            end
        end
    end
    return colors
end

local function CountChangedButtons(colorsFolder, initialColors)
    if not colorsFolder or not initialColors then return 0 end
    local currentColors = GetButtonColors(colorsFolder)
    local changed = 0
    for i = 1, math.min(#initialColors, #currentColors) do
        if initialColors[i] ~= currentColors[i] then
            changed = changed + 1
        end
    end
    return changed
end

local function GetPromptByActionText(actionText, searchRoot)
    if not actionText or actionText == "" then return nil end
    if not searchRoot then searchRoot = Workspace end
    local targetText = string.lower(actionText)
    for _, desc in ipairs(searchRoot:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Enabled and desc.ActionText then
            local lowerAction = string.lower(desc.ActionText)
            if string.find(lowerAction, targetText) or string.find(targetText, lowerAction) then
                return desc
            end
        end
    end
    return nil
end

local function AutoRoom6Sequence()
    local emergency = GetEmergencyRooms()
    if not emergency then return end
    local room6 = emergency:FindFirstChild("Room6")
    if not room6 then return end
    local minigame = room6:FindFirstChild("Minigame")
    if not minigame then return end
    print("🔄 Starting Auto Room 6...")
    local xrayMonitor = FindXrayMonitorInMinigame(room6)
    if xrayMonitor then
        local xrayPrompt = xrayMonitor:FindFirstChild("PP")
        if xrayPrompt and xrayPrompt:IsA("ProximityPrompt") and xrayPrompt.Enabled then
            local part = FindBasePartInObject(xrayMonitor)
            if part then
                print("📸 Interacting with Begin X-Ray...")
                SafeTeleport(part.Position)
                FirePromptWithCamera(xrayPrompt, part.Position)
                wait(0.5)
            end
        end
    end
    local colorsFolder = FindColorsInMinigame(room6)
    if not colorsFolder then
        print("❌ Colors folder not found!")
        return
    end
    local initialColors = GetButtonColors(colorsFolder)
    local buttons = GetButtonModels(colorsFolder)
    if #buttons < 4 then
        print("❌ Less than 4 buttons found!")
        return
    end
    print("🎨 Waiting for 4 buttons to change color...")
    local timeout = 0
    local changedCount = 0
    local maxWaitTime = 15
    while timeout < maxWaitTime and changedCount < 4 do
        wait(0.2)
        changedCount = CountChangedButtons(colorsFolder, initialColors)
        timeout = timeout + 0.2
    end
    print("✅ " .. changedCount .. " buttons changed color (expected: 4)")
    print("⏳ Waiting 1.5 seconds...")
    wait(1.5)
    print("🔘 Clicking buttons...")
    local clickedCount = 0
    for _, btn in ipairs(buttons) do
        if btn and btn:IsA("BasePart") then
            SafeTeleport(btn.Position + Vector3.new(0, 1, 2))
            LookAtPosition(btn.Position)
            wait(0.2)
            if ClickButton(btn) then
                clickedCount = clickedCount + 1
                print("✅ Button " .. clickedCount .. " clicked")
            end
            wait(0.15)
        end
    end
    print("✅ " .. clickedCount .. " buttons clicked")
    print("⏳ Waiting for 'Process Results'...")
    local processPrompt = nil
    local processTimeout = 0
    while processTimeout < 10 do
        processPrompt = GetPromptByActionText("process results", minigame)
        if processPrompt then break end
        wait(0.3)
        processTimeout = processTimeout + 0.3
    end
    if processPrompt then
        local part = FindBasePartInObject(processPrompt.Parent)
        if part then
            print("📄 Interacting with Process Results...")
            SafeTeleport(part.Position)
            FirePromptWithCamera(processPrompt, part.Position)
            wait(0.5)
        end
    else
        print("⚠️ 'Process Results' not found!")
    end
    print("⏳ Waiting for 'Print Badge'...")
    local printBadgePrompt = nil
    local badgeTimeout = 0
    while badgeTimeout < 10 do
        printBadgePrompt = GetPromptByActionText("print badge", minigame)
        if printBadgePrompt then break end
        wait(0.3)
        badgeTimeout = badgeTimeout + 0.3
    end
    if printBadgePrompt then
        local part = FindBasePartInObject(printBadgePrompt.Parent)
        if part then
            print("🖨️ Interacting with Print Badge...")
            SafeTeleport(part.Position)
            FirePromptWithCamera(printBadgePrompt, part.Position)
            wait(0.5)
        end
    else
        print("⚠️ 'Print Badge' not found!")
    end
    print("🔍 Searching for 'Collect' in Workspace...")
    local collectPrompt = nil
    local collectTimeout = 0
    while collectTimeout < 8 do
        collectPrompt = GetPromptByActionText("collect", Workspace)
        if collectPrompt then break end
        wait(0.3)
        collectTimeout = collectTimeout + 0.3
    end
    if collectPrompt then
        local part = FindBasePartInObject(collectPrompt.Parent)
        if part then
            print("📦 Interacting with Collect...")
            SafeTeleport(part.Position)
            FirePromptWithCamera(collectPrompt, part.Position)
            wait(0.3)
        end
    else
        print("⚠️ 'Collect' not found!")
    end
    print("✅ Auto Room 6 completed successfully!")
end

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Config.AutoRoom6 then
            AutoRoom6Sequence()
            print("⏳ Waiting 3 seconds before restarting Room 6...")
            wait(3)
        end
    end
end)

-- ==========================================
-- GLOBAL AUTO PROCESS
-- ==========================================
local function ProcessGlobalRooms()
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if not Config.AutoProcess then break end
        if desc:IsA("ProximityPrompt") and desc.Enabled and desc.ActionText then
            local txt = string.lower(desc.ActionText)
            if string.find(txt, "dna") or string.find(txt, "analyze") or string.find(txt, "process") then
                local part = FindBasePartInObject(desc.Parent)
                if part then
                    SafeTeleport(part.Position)
                    FirePromptDirect(desc)
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Config.AutoProcess then
            ProcessGlobalRooms()
        end
    end
end)

-- ==========================================
-- ROOM 7 & 8 HELPERS
-- ==========================================
local function FindInBedInRoom(room)
    if not room then return nil end
    for _, child in ipairs(room:GetChildren()) do
        if child:IsA("Model") or child:IsA("BasePart") then
            local name = child.Name:lower()
            if string.find(name, "bed") or string.find(name, "inbed") then
                return child
            end
        end
    end
    return room
end

-- ==========================================
-- AUTO ROOM 7
-- ==========================================
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Config.AutoRoom7 then
            local emergency = GetEmergencyRooms()
            local room7 = emergency and emergency:FindFirstChild("Room7")
            if room7 then
                local inBed = FindInBedInRoom(room7)
                if inBed then
                    for _, prompt in ipairs(inBed:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            local text = string.lower(prompt.ActionText or "")
                            local targets = {"sleep", "prepare", "set up", "turn on", "begin", "collect"}
                            for _, target in ipairs(targets) do
                                if string.find(text, target) then
                                    local part = FindBasePartInObject(prompt.Parent)
                                    if part then
                                        SafeTeleport(part.Position)
                                        FirePromptDirect(prompt)
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- AUTO ROOM 8
-- ==========================================
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Config.AutoRoom8 then
            local emergency = GetEmergencyRooms()
            local room8 = emergency and emergency:FindFirstChild("Room8")
            if room8 then
                local inBed = FindInBedInRoom(room8)
                if inBed then
                    for _, prompt in ipairs(inBed:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            local text = string.lower(prompt.ActionText or "")
                            if string.find(text, "sleep") or string.find(text, "patient") then
                                local part = FindBasePartInObject(prompt.Parent)
                                if part then
                                    SafeTeleport(part.Position)
                                    FirePromptDirect(prompt)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- PROMPT HOOK & NOCLIP
-- ==========================================
local function HookPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if Config.InstantAction then prompt.HoldDuration = 0 end
end

Workspace.DescendantAdded:Connect(HookPrompt)
for _, p in ipairs(Workspace:GetDescendants()) do HookPrompt(p) end

local OriginalCollisions = {}

local function SaveOriginalCollisions()
    local char = GetCharacter()
    if not char or next(OriginalCollisions) ~= nil then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then OriginalCollisions[part] = part.CanCollide end
    end
end

local function RestoreOriginalCollisions()
    local char = GetCharacter()
    if not char then return end
    for part, canCollide in pairs(OriginalCollisions) do
        if part and part.Parent then part.CanCollide = canCollide end
    end
    OriginalCollisions = {}
end

local function ApplyNoClip()
    local char = GetCharacter()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not Config.NoClip
        end
    end
end

RunService.Heartbeat:Connect(function()
    local hum = GetHumanoid()
    if hum then hum.WalkSpeed = Config.WalkSpeed end
    if Config.NoClip then
        SaveOriginalCollisions()
        ApplyNoClip()
    else
        RestoreOriginalCollisions()
    end
end)

-- ==========================================
-- AUTO CHECK IN
-- ==========================================
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Config.AutoCheckIn then
            pcall(function()
                local reception = Workspace:FindFirstChild("Reception")
                if reception then
                    local triggers = reception:FindFirstChild("CheckInTriggers")
                    if triggers then
                        for _, v in ipairs(triggers:GetChildren()) do
                            if v:IsA("BasePart") then
                                player.Character.HumanoidRootPart.CFrame = v.CFrame
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end
end)

-- ==========================================
-- AUTO BARNEY COFFEE
-- ==========================================
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Config.AutoBarneyCoffee then
            pcall(function()
                local npcs = Workspace:FindFirstChild("NPCs")
                if npcs then
                    local barney = npcs:FindFirstChild("Barney")
                    if barney then
                        local args = {
                            [1] = "GiveCoffee",
                            [2] = barney
                        }
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes then
                            local interaction = remotes:FindFirstChild("Interaction")
                            if interaction then
                                interaction:FireServer(unpack(args))
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end
end)

-- ==========================================
-- AUTO PROCESS PATIENTS (AutoTreat)
-- ==========================================
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if Config.AutoTreat then
            pcall(function()
                local patients = Workspace:FindFirstChild("Patients")
                if patients then
                    for _, v in ipairs(patients:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") then
                            player.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                            if remotes then
                                local treat = remotes:FindFirstChild("TreatPatient")
                                if treat then
                                    treat:FireServer(v)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end
end)

-- ==========================================
-- AUTO FARM (treat patients via prompts)
-- ==========================================
task.spawn(function()
    while true do
        task.wait(Config.FarmDelay or 1.5)
        if Config.AutoFarm then
            local patients = findPatients()
            for _, patient in ipairs(patients) do
                healPatient(patient)
                task.wait(0.3)
            end
        end
    end
end)

-- ==========================================
-- AUTO REJECT ANOMALIES
-- ==========================================
task.spawn(function()
    while true do
        task.wait(1)
        if Config.AutoReject then
            rejectAnomaly()
        end
    end
end)

-- ==========================================
-- EXPOSE FUNCTIONS & CONFIG
-- ==========================================
local Utility = {
    Config = Config,
    GetCharacter = GetCharacter,
    GetHumanoid = GetHumanoid,
    GetRootPart = GetRootPart,
    FindBasePartInObject = FindBasePartInObject,
    SafeTeleport = SafeTeleport,
    LookAtPosition = LookAtPosition,
    FirePromptDirect = FirePromptDirect,
    FirePromptWithCamera = FirePromptWithCamera,
    ClickButton = ClickButton,
    GetCachedItemPrompt = GetCachedItemPrompt,
    RefreshItemCache = RefreshItemCache,
    findPatients = findPatients,
    findAnomalies = findAnomalies,
    healPatient = healPatient,
    rejectAnomaly = rejectAnomaly,
    updateESP = updateESP,
    clearESP = clearESP,
    GetEmergencyRooms = GetEmergencyRooms,
    AutoRoom6Sequence = AutoRoom6Sequence,
    ProcessGlobalRooms = ProcessGlobalRooms,
    startInfiniteSanity = startInfiniteSanity,
    stopInfiniteSanity = stopInfiniteSanity,
}

-- Make it globally accessible for Main
getgenv().Utility = Utility

print("✅ Utility loaded successfully. Ready for Main.")
return Utility
```

---