-- =================================================================
-- LIBRARY SELECTION INTERFACE (Rayfield vs Luna)
-- =================================================================
 
local SelectionScreen = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Subtitle = Instance.new("TextLabel")
local RayfieldBtn = Instance.new("TextButton")
local LunaBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UICorner2 = Instance.new("UICorner")
local UICorner3 = Instance.new("UICorner")
 
SelectionScreen.Name = "LibrarySelector"
SelectionScreen.Parent = game:GetService("CoreGui")
SelectionScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
 
MainFrame.Name = "MainFrame"
MainFrame.Parent = SelectionScreen
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
MainFrame.Size = UDim2.new(0, 350, 0, 200)
 
UICorner.Parent = MainFrame
 
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "RyaPlays Script Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22.000
 
Subtitle.Name = "Subtitle"
Subtitle.Parent = MainFrame
Subtitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Subtitle.BackgroundTransparency = 1.000
Subtitle.Position = UDim2.new(0, 0, 0, 35)
Subtitle.Size = UDim2.new(1, 0, 0, 30)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Choose your preferred UI Library Layout:"
Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
Subtitle.TextSize = 14.000
 
RayfieldBtn.Name = "RayfieldBtn"
RayfieldBtn.Parent = MainFrame
RayfieldBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
RayfieldBtn.Position = UDim2.new(0.08, 0, 0.55, 0)
RayfieldBtn.Size = UDim2.new(0.38, 0, 0, 45)
RayfieldBtn.Font = Enum.Font.GothamBold
RayfieldBtn.Text = "Rayfield Library"
RayfieldBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RayfieldBtn.TextSize = 14.000
 
UICorner2.Parent = RayfieldBtn
 
LunaBtn.Name = "LunaBtn"
LunaBtn.Parent = MainFrame
LunaBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 140)
LunaBtn.Position = UDim2.new(0.54, 0, 0.55, 0)
LunaBtn.Size = UDim2.new(0.38, 0, 0, 45)
LunaBtn.Font = Enum.Font.GothamBold
LunaBtn.Text = "Luna Library (W.I.P)"
LunaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LunaBtn.TextSize = 13.000
 
UICorner3.Parent = LunaBtn
 
-- =================================================================
-- OPTION 1: LOAD RAYFIELD LAYOUT
-- =================================================================
 
local function LoadRayfieldLayout()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
 
    local Window = Rayfield:CreateWindow({
       Name = "RyaPlays Script Hub",
       LoadingTitle = "Loading Elements...",
       LoadingSubtitle = "by RyaPlays2763Cool",
       ConfigurationSaving = {
          Enabled = true,
          FolderName = "RayfieldHubConfig", 
          FileName = "MainHub"
       },
       Discord = { Enabled = false, Invite = "noinvite", RememberJoins = true },
       KeySystem = true,
       KeySettings = {
          Title = "Key Verification",
          Subtitle = "Who Made This Script?",
          Note = "Enter the correct key to access the script hub.",
          FileName = "RayfieldKey", 
          SaveKey = true, 
          GrabKeyFromUrl = "", 
          Key = {"RyaExploitzLol"}
       }
    })
 
    -- Tabs
    local MainTab = Window:CreateTab("Main Features", 4483362458) 
    local ToonTab = Window:CreateTab("Toon maker", 4483362458)
    local PlayerTab = Window:CreateTab("Player Tweaks", 4483362458)
    local PromoTab = Window:CreateTab("Promotions", 4483362458)
 
    local MainSection = MainTab:CreateSection("Character & Physics")
 
    MainTab:CreateButton({
       Name = "Become Character",
       Callback = function()
           print("Become Character executed!")
       end,
    })
 
    MainTab:CreateInput({
       Name = "Orbit (Name)",
       PlaceholderText = "Target Player Name",
       RemoveTextAfterFocusLost = false,
       Callback = function(Text)
           print("Orbiting target player: " .. Text)
       end,
    })
 
    local ToonSection = ToonTab:CreateSection("Toon Editor Settings")
    ToonTab:CreateLabel("Customize or modify toon assets here.")
 
    PlayerTab:CreateSlider({
       Name = "Walkspeed Changer",
       Range = {16, 150},
       Increment = 1,
       Suffix = " Speed",
       CurrentValue = 16,
       Flag = "Slider1", 
       Callback = function(Value)
           if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
               game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
           end
       end,
    })
 
    -- Promotions Section
    local PromoSection = PromoTab:CreateSection("Promoted Hubs")
 
    PromoTab:CreateButton({
       Name = "Sprout Scary Hub | Dandy World",
       Callback = function()
          loadstring(game:HttpGet("https://pastebin.com/raw/VLCVgPrD"))()
       end,
    })
 
    PromoTab:CreateButton({
       Name = "Boxten S** GUI\" | Team Noxious",
       Callback = function()
          loadstring(game:HttpGet("https://raw.githubusercontent.com/Team-Noxious/Roblox/refs/heads/main/Loader.lua"))("Boxten Sex GUI")
       end,
    })
 
    Rayfield:Notify({
       Title = "Script Loaded Successfully",
       Content = "Enjoy using the RyaPlays Hub!",
       Duration = 5,
       Image = 4483362458,
    })
end
 
-- =================================================================
-- OPTION 2: LOAD LUNA LAYOUT (W.I.P)
-- =================================================================
 
local function LoadLunaLayout()
    local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Singularity-V1/Luna-UI-Library/main/Source.lua"))()
 
    local Window = Luna:CreateWindow({
       Name = "Luna library (W.I.P)", 
       Subtitle = "by RyaPlays2763Cool",
       LogoID = "rbxassetid://4483362458",
       LoadingEnabled = true,
       LoadingTitle = "Loading Assets...",
       LoadingUser = "Welcome!"
    })
 
    local MainTab = Window:CreateTab({ Name = "Main Features", Icon = "rbxassetid://4483362458" })
    local MainSection = MainTab:CreateSection({ Name = "Character & Physics" })
 
    MainSection:CreateButton({
        Name = "Become Character",
        Description = "Transform character model properties",
        Callback = function()
            print("Become Character executed!")
        end
    })
 
    MainSection:CreateButton({
        Name = "Orbit (Name)",
        Description = "Orbit targeted string identifier",
        Callback = function()
            print("Orbit active.")
        end
    })
 
    local ToonTab = Window:CreateTab({ Name = "Toon maker", Icon = "rbxassetid://4483362458" })
    local ToonSection = ToonTab:CreateSection({ Name = "Toon Editor Settings" })
 
    local PlayerTab = Window:CreateTab({ Name = "Player Tweaks", Icon = "rbxassetid://4483362458" })
    local PlayerSection = PlayerTab:CreateSection({ Name = "Movement" })
 
    PlayerSection:CreateSlider({
        Name = "Walkspeed",
        Min = 16,
        Max = 150,
        Default = 16,
        Callback = function(Value)
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end
    })
 
    local PromoTab = Window:CreateTab({ Name = "Promotions", Icon = "rbxassetid://4483362458" })
    local PromoSection = PromoTab:CreateSection({ Name = "Promoted Hubs" })
 
    PromoSection:CreateButton({
        Name = "Sprout Scary Hub | Dandy World",
        Callback = function()
            loadstring(game:HttpGet("https://pastebin.com/raw/VLCVgPrD"))()
        end
    })
 
    PromoSection:CreateButton({
        Name = "Boxten S** GUI\" | Team Noxious",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Team-Noxious/Roblox/refs/heads/main/Loader.lua"))("Boxten Sex GUI")
        end
    })
end
 
-- =================================================================
-- SELECTION CONNECTION TRIGGERS
-- =================================================================
 
RayfieldBtn.MouseButton1Click:Connect(function()
    SelectionScreen:Destroy()
    LoadRayfieldLayout()
end)
 
LunaBtn.MouseButton1Click:Connect(function()
    SelectionScreen:Destroy()
    LoadLunaLayout()
end)
 