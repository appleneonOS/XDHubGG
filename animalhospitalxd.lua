local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success or not Rayfield then return end

-- LOAD YOUR UTILITY MODULARLY
local Utils = loadstring(game:HttpGet("https://github.com/appleneonOS/XDHubGG/raw/main/utility.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "XDHub - Animal Hospital",
    LoadingTitle = "Loading XDHub..",
    LoadingSubtitle = "by Shellae.",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {Enabled = true, FileName = "XDHub_AnimalHospital"}
})

local MainTab = Window:CreateTab("Main", nil)
local PlayerTab = Window:CreateTab("Player", nil) -- Added for Riddance style
local VisualTab = Window:CreateTab("Visual", nil)

local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local Toggles = {AutoProcess = false, DoorAura = false, NpcESP = false}
local ActiveHighlights = {}

-- Character/Player Mods (Riddance Style)
PlayerTab:CreateSlider({
    Name = "WalkSpeed Hack",
    Min = 16,
    Max = 150,
    CurrentValue = 16,
    Flag = "WalkspeedSlider",
    Callback = function(Value)
        Utils.setSpeed(Value)
    end
})

-- Auto Process Event Using Modular Filter
local ProcessKeywords = {"Stamp", "Form", "Photo", "Register", "Badge", "Take", "Talk"}
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

MainTab:CreateToggle({
    Name = "Auto Process",
    CurrentValue = false,
    Flag = "AutoProcess",
    Callback = function(v) Toggles.AutoProcess = v end
})

-- NPC ESP using utility checks
local function updateESP()
    for _, v in ipairs(ActiveHighlights) do pcall(function() v:Destroy() end) end
    ActiveHighlights = {}
    
    if not Toggles.NpcESP then return end
    local npcs = workspace:FindFirstChild("NPCs")
    if npcs then
        for _, npc in ipairs(npcs:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                if Utils.isAnomaly(npc) or Utils.isPatient(npc) then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Utils.isAnomaly(npc) and Color3.fromRGB(255,30,30) or Color3.fromRGB(0,255,127)
                    highlight.Parent = npc
                    table.insert(ActiveHighlights, highlight)
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(3) do pcall(updateESP) end
end)

VisualTab:CreateToggle({
    Name = "NPC ESP",
    CurrentValue = false,
    Flag = "NpcESP",
    Callback = function(v) Toggles.NpcESP = v updateESP() end
})
