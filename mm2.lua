-- Murder Mystery 2 ESP System
-- Shows player roles with text labels only (no boxes)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local ESP_CONFIG = {
    enabled = true,
    textSize = 18,
    updateRate = 0.1,
    maxDistance = 500,
}

-- Role colors
local COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),       -- Red
    Sheriff = Color3.fromRGB(0, 100, 255),     -- Blue
    Innocent = Color3.fromRGB(0, 255, 0),      -- Green
}

-- Cache for ESP drawables
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

-- Function to create or update ESP for a player
local function updateESP(player)
    if player == Players.LocalPlayer then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local humanoidRootPart = character.HumanoidRootPart
    local role = getPlayerRole(player)
    local color = COLORS[role] or COLORS.Innocent
    
    -- Create ESP label if it doesn't exist
    if not espCache[player.UserId] then
        local bill = Instance.new("BillboardGui")
        bill.Name = "ESP_Label"
        bill.Size = UDim2.new(4, 0, 1.5, 0)
        bill.MaxDistance = ESP_CONFIG.maxDistance
        bill.Adornee = humanoidRootPart
        bill.StudsOffset = Vector3.new(0, 3, 0)
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "Role"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextScaled = true
        textLabel.TextSize = ESP_CONFIG.textSize
        textLabel.BorderSizePixel = 0
        textLabel.TextColor3 = color
        
        textLabel.Parent = bill
        bill.Parent = humanoidRootPart
        
        espCache[player.UserId] = {
            billboard = bill,
            textLabel = textLabel,
            lastRole = role
        }
    end
    
    -- Update role text and colors
    local esp = espCache[player.UserId]
    esp.textLabel.Text = role
    esp.textLabel.TextColor3 = color
    esp.lastRole = role
end

-- Function to remove ESP for a player
local function removeESP(userId)
    if espCache[userId] then
        if espCache[userId].billboard then
            espCache[userId].billboard:Destroy()
        end
        espCache[userId] = nil
    end
end

-- Main ESP update loop
local function espLoop()
    while ESP_CONFIG.enabled do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                pcall(function()
                    updateESP(player)
                end)
            end
        end
        wait(ESP_CONFIG.updateRate)
    end
end

-- Player added connection
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(0.1)
        updateESP(player)
    end)
end)

-- Player removing connection
Players.PlayerRemoving:Connect(function(player)
    removeESP(player.UserId)
end)

-- Toggle ESP with 'E' key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        ESP_CONFIG.enabled = not ESP_CONFIG.enabled
        print("ESP " .. (ESP_CONFIG.enabled and "Enabled" or "Disabled"))
    end
end)

-- Update existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer and player.Character then
        wait(0.05)
        updateESP(player)
    end
end

-- Start ESP loop
task.spawn(espLoop)

print("Murder Mystery 2 ESP loaded! Press 'E' to toggle.")
print("Murderer: RED | Sheriff: BLUE | Innocent: GREEN")