-- ==========================================
-- main.lua – Animal Hospital XDHub
-- Connects to utility.lua (must be loaded first)
-- Tabs: Main | ESP | Settings
-- ==========================================

-- Load Utility and Config from utility.lua
local Utility = getgenv().Utility
if not Utility then
    warn("❌ utility.lua not loaded! Please run utility.lua first.")
    return
end
local Config = Utility.Config   -- Direct reference

-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- ==========================================
-- WINDOW (custom name and loading text)
-- ==========================================
local Window = Rayfield:CreateWindow({
    Name = "Animal Hospital - XDHub",   -- Window title
    LoadingTitle = "Enjoy!",
    LoadingSubtitle = "by Shellae",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AnimalHospitalXDHub",
        FileName = "Settings"
    },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- ==========================================
-- TABS (only Main, ESP, Settings)
-- ==========================================
local MainTab = Window:CreateTab("Main")
local ESPTab = Window:CreateTab("ESP")
local SettingsTab = Window:CreateTab("Settings")

-- ==========================================
-- MAIN TAB
-- ==========================================
MainTab:CreateSection("Auto Farm")

MainTab:CreateToggle({
    Name = "Auto Treat Patients",
    CurrentValue = false,
    Callback = function(value) Config.AutoFarm = value end
})

MainTab:CreateToggle({
    Name = "Auto Reject Anomalies",
    CurrentValue = false,
    Callback = function(value) Config.AutoReject = value end
})

MainTab:CreateSection("Sanity")

MainTab:CreateToggle({
    Name = "Infinite Sanity",
    CurrentValue = false,
    Callback = function(value) Config.InfiniteSanity = value end
})

MainTab:CreateSection("Interaction")

MainTab:CreateToggle({
    Name = "Instant Action (no hold)",
    CurrentValue = false,
    Callback = function(value) Config.InstantAction = value end
})

MainTab:CreateSection("Movement")

MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 50},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(value) Config.WalkSpeed = value end
})

MainTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(value) Config.NoClip = value end
})

-- ==========================================
-- ESP TAB
-- ==========================================
ESPTab:CreateSection("ESP Toggles")

local espAnomaly = ESPTab:CreateToggle({
    Name = "ESP Anomalies (Skinwalker)",
    CurrentValue = false,
    Callback = function(value) Config.ESPAnomaly = value end
})

local espPatient = ESPTab:CreateToggle({
    Name = "ESP Patients",
    CurrentValue = false,
    Callback = function(value) Config.ESPPatient = value end
})

local espVisitor = ESPTab:CreateToggle({
    Name = "ESP Visitors",
    CurrentValue = false,
    Callback = function(value) Config.ESPVisitor = value end
})

ESPTab:CreateButton({
    Name = "Clear All ESP",
    Callback = function()
        Utility.clearESP()
        espAnomaly:SetValue(false)
        espPatient:SetValue(false)
        espVisitor:SetValue(false)
    end
})

-- ==========================================
-- SETTINGS TAB
-- ==========================================
SettingsTab:CreateSection("Hub Settings")

SettingsTab:CreateKeybind({
    Name = "Toggle GUI",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Callback = function() Window:Toggle() end
})

SettingsTab:CreateButton({
    Name = "Reset All Settings",
    Callback = function()
        Rayfield:Destroy()
        print("Settings reset. Re-run the script to reload.")
    end
})

print("✅ Animal Hospital - XDHub loaded successfully!")