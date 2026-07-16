-- Murder Mystery 2 ESP System
-- Shows player roles with outlines (no text labels)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local ESP_CONFIG = {
    enabled = true,
    lineThickness = 0.05,
    updateRate = 0.1,
    maxDistance = 500,
}

-- Role colors
local COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),       -- Red
    Sheriff = Color3.fromRGB(0, 100, 255),     -- Blue
    Innocent = Color3.fromRGB(0, 255, 0),      -- Green
}

-- Cache for ESP outlines
local espCache = {}

-- Function to get player role
local function getPlayerRole(player)
    local role = "Innocent"
    
    -- Check backpack
    if player:FindFirstChild("Backpack") then
        for _, item in pairs(player.Backpack:GetChildren()) do
            if item.Name == "Murder" then
                role = "Murderer"
            elseif item.Name == "Gun" or item.Name == "Revolver" then
                role = "Sheriff"
            end
        end
    end
    
    -- Check character
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        for _, item in pairs(player.Character:GetChildren()) do
            if item.Name == "Murder" then
                role = "Murderer"
            elseif item.Name == "Gun" or item.Name == "Revolver" then
                role = "Sheriff"
            end
        end
    end
    
    return role
end

-- Function to add outlines to character parts
local function addOutlines(character, color)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if not part:FindFirstChild("ESP_Outline") then
                local outline = Instance.new("SelectionBox")
                outline.Name = "ESP_Outline"
                outline.Adornee = part
                outline.Color3 = color
                outline.LineThickness = ESP_CONFIG.lineThickness
                outline.Parent = part
            end
        end
    end
end

-- Function to remove outlines from character
local function removeOutlines(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            local outline = part:FindFirstChild("ESP_Outline")
            if outline then
                outline:Destroy()
            end
        end
    end
end

-- Function to update ESP for a player
local function updateESP(player)
    if player == Players.LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local role = getPlayerRole(player)
    local color = COLORS[role] or COLORS.Innocent
    
    if ESP_CONFIG.enabled then
        addOutlines(character, color)
    else
        removeOutlines(character)
    end
end

-- Function to remove all ESP for a player
local function removeESP(player)
    if player.Character then
        removeOutlines(player.Character)
    end
end

-- Main ESP update loop
local function espLoop()
    while true do
        if ESP_CONFIG.enabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer then
                    pcall(function()
                        updateESP(player)
                    end)
                end
            end
        end
        wait(ESP_CONFIG.updateRate)
    end
end

-- Player added connection
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(0.1)
        if ESP_CONFIG.enabled then
            updateESP(player)
        end
    end)
end)

-- Player removing connection
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Toggle ESP with 'E' key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        ESP_CONFIG.enabled = not ESP_CONFIG.enabled
        print("ESP " .. (ESP_CONFIG.enabled and "Enabled" or "Disabled"))
        
        -- Update all players when toggling
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                pcall(function()
                    updateESP(player)
                end)
            end
        end
    end
end)

-- Start ESP loop
task.spawn(espLoop)

print("Murder Mystery 2 ESP loaded!")
print("Press 'E' to toggle ESP")
print("Murderer: RED | Sheriff: BLUE | Innocent: GREEN")