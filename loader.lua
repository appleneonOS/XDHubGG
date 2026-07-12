-- ==========================================
-- LOADER – Animal Hospital XDHub
-- Loads all components from GitHub
-- ==========================================

print("🚀 Loading Animal Hospital - XDHub...")

-- 1. Load Rayfield UI Library (required for the GUI)
local rayfieldLoaded, rayfieldErr = pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
end)
if not rayfieldLoaded then
    warn("❌ Failed to load Rayfield: " .. tostring(rayfieldErr))
    return
end

-- 2. Load Utility (backend logic)
local utilityLoaded, utilityErr = pcall(function()
    loadstring(game:HttpGet("https://github.com/appleneonOS/XDHubGG/raw/main/utility.lua"))()
end)
if not utilityLoaded then
    warn("❌ Failed to load utility.lua: " .. tostring(utilityErr))
    return
end

-- 3. Load Main (GUI)
local mainLoaded, mainErr = pcall(function()
    loadstring(game:HttpGet("https://github.com/appleneonOS/XDHubGG/raw/main/main.lua"))()
end)
if not mainLoaded then
    warn("❌ Failed to load main.lua: " .. tostring(mainErr))
    return
end

print("✅ Animal Hospital - XDHub fully loaded!")