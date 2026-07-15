-- Auto-Process Proximity Prompt for Animal Hospital (Roblox)
-- This script automatically triggers proximity prompts when players get close

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local PROXIMITY_RANGE = 25 -- Distance to trigger prompt (in studs)
local UPDATE_INTERVAL = 0.1 -- Check interval in seconds
local AUTO_PROCESS_ENABLED = true -- Always enabled

-- Proximity Prompt Detection System
local function findNearbyPrompts()
    local workspace = game:GetService("Workspace")
    local prompts = {}
    
    -- Search for ProximityPrompts in workspace
    local function findPrompts(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("ProximityPrompt") then
                local distance = (humanoidRootPart.Position - child.Parent.Position).Magnitude
                if distance <= PROXIMITY_RANGE then
                    table.insert(prompts, {
                        prompt = child,
                        distance = distance,
                        parent = child.Parent
                    })
                end
            end
            
            -- Recursively search children
            findPrompts(child)
        end
    end
    
    findPrompts(workspace)
    
    -- Sort by distance (closest first)
    table.sort(prompts, function(a, b)
        return a.distance < b.distance
    end)
    
    return prompts
end

-- Auto-trigger the closest prompt
local function autoTriggerPrompt()
    if not AUTO_PROCESS_ENABLED then return end
    
    local prompts = findNearbyPrompts()
    
    if #prompts > 0 then
        local closestPrompt = prompts[1]
        local prompt = closestPrompt.prompt
        
        -- Trigger the prompt
        if prompt and prompt.Parent then
            prompt:InputHoldBegin()
            wait(0.1)
            prompt:InputHoldEnd()
        end
    end
end

-- Main loop - Auto execute continuously
local lastTriggerTime = 0
local TRIGGER_COOLDOWN = 0.5 -- Cooldown between auto-triggers (seconds)

RunService.Heartbeat:Connect(function()
    if not character or not humanoidRootPart or not humanoidRootPart.Parent then
        return
    end
    
    local currentTime = tick()
    
    -- Auto-trigger with cooldown - ALWAYS RUNNING
    if currentTime - lastTriggerTime >= TRIGGER_COOLDOWN then
        autoTriggerPrompt()
        lastTriggerTime = currentTime
    end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("✓ Auto-Proximity Prompt System Loaded!")
print("✓ Auto-Execute ACTIVE - Prompts will trigger automatically!")
