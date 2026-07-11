local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success or not Rayfield then return end

local Window = nil
local winSuccess, winErr = pcall(function()
    Window = Rayfield:CreateWindow({
        Name = "XDHub - Animal Hospital",
        LoadingTitle = "Loading XDHub..",
        LoadingSubtitle = "by Shellae.",
        Theme = "Default",
        ToggleUIKeybind = "K",
        ConfigurationSaving = {Enabled = false, FileName = "XDHub_AH"}
    })
end)

if not winSuccess or not Window then 
    warn("Window creation failed: " .. tostring(winErr))
    return 
end

-- Create Tabs safely
local MainTab = Window:CreateTab("Main", nil)
local PlayerTab = Window:CreateTab("Player", nil)
local VisualTab = Window:CreateTab("Visual", nil)

local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Toggles = {AutoProcess = false, NpcESP = false}
local ActiveHighlights = {}

-- Load utility safely with a fallback
local Utils = nil
pcall(function()
    Utils = loadstring(game:HttpGet("https://github.com/appleneonOS/XDHubGG/raw/main/utility.lua"))()
end)

-- ==================== SYSTEM TEST ====================
pcall(function()
    MainTab:CreateButton({
        Name = "Emergency UI Test Button",
        Callback = function()
            Rayfield:Notify({Title = "Test", Content = "UI is working perfectly!", Duration = 2})
        end,
    })
end)

-- ==================== MAIN TAB ====================
pcall(function()
    MainTab:CreateToggle({
        Name = "Auto Process",
        CurrentValue = false,
        Flag = "AutoProcessToggle",
        Callback = function(v) 
            Toggles.AutoProcess = v 
        end
    })
end)

-- ==================== PLAYER TAB ====================
pcall(function()
    PlayerTab:CreateSlider({
        Name = "WalkSpeed Hack",
        Min = 16,
        Max = 150,
        CurrentValue = 16,
        Flag = "WS_Slider",
        Callback = function(Value)
            if Utils and Utils.setSpeed then
                pcall(function() Utils.setSpeed(Value) end)
            else
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = Value end
            end
        end
    })
end)

-- ==================== VISUAL TAB ====================
local function updateESP()
    for _, v in ipairs(ActiveHighlights) do pcall(function() v:Destroy() end) end
    ActiveHighlights = {}
    if not Toggles.NpcESP then return end
    
    local npcs = workspace:FindFirstChild("NPCs")
    if npcs and Utils then
        for _, npc in ipairs(npcs:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                local isAnom = false
                local isPat = false
                pcall(function() isAnom = Utils.isAnomaly(npc) end)
                pcall(function() isPat = Utils.isPatient(npc) end)
                
                if isAnom or isPat then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = isAnom and Color3.fromRGB(255,30,30) or Color3.fromRGB(0,255,127)
                    highlight.Parent = npc
                    table.insert(ActiveHighlights, highlight)
                end
            end
        end
    end
end

pcall(function()
    VisualTab:CreateToggle({
        Name = "NPC ESP",
        CurrentValue = false,
        Flag = "EspToggle",
        Callback = function(v) 
            Toggles.NpcESP = v 
            updateESP() 
        end
    })
end)

-- Background connections
local ProcessKeywords = {"Stamp", "Form", "Photo", "Register", "Badge", "Take", "Talk"}
pcall(function()
    ProximityPromptService.PromptShown:Connect(function(prompt)
        if not Toggles.AutoProcess then return end
        local nameLower = prompt.Name:lower()
        for _, keyword in ipairs(ProcessKeywords) do
            if nameLower:find(keyword:lower()) then
                prompt.MaxActivationDistance = 50
                prompt.HoldDuration = 0
                fireproximityprompt(prompt)
            end
        end
    end)
end)

task.spawn(function()
    while task.wait(3) do 
        pcall(updateESP) 
    end
end)
