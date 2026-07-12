-- Dandy's World Utility Library
-- API wrapper for the Roblox game "Dandy's World"

-- Wait for game to load
if not game.IsLoaded(game) then
    game.Loaded:Wait()
end

-- Load the Utility library from GitHub
local Utility = loadstring(
    game:HttpGet("https://github.com/riddance-club/library/releases/latest/download/Utility.lua")
)()

-- Cache important game objects
local Players = Utility.services.Players
local InfoFolder = workspace:FindFirstChild('Info')
local InGamePlayers = workspace:FindFirstChild('InGamePlayers')
local CurrentRoom = workspace:FindFirstChild('CurrentRoom')
local ElevatorsFolder = workspace:FindFirstChild('Elevators')

local Elevator = ElevatorsFolder and ElevatorsFolder:FindFirstChild('Elevator')
local GameData = {}
local API = {}

-- Store InfoFolder data
if InfoFolder then
    API.InfoData = {}
    for _, valueObject in InfoFolder:GetChildren() do
        if valueObject:IsA('ValueBase') then
            API.InfoData[valueObject.Name] = valueObject
        end
    end
end

-- Initialize API structure
API.Game = {}
API.Generators = {}
API.Players = {}
API.Twisteds = {}
API.Items = {}
API.Map = {}
API.Utility = Utility

-- --- GAME STATE FUNCTIONS ---

-- Check if game is running (not in lobby)
function API.Game.IsRun()
    return Utility.IsValid(CurrentRoom)
end

-- Check if in lobby
function API.Game.IsLobby()
    return not API.Game.IsRun()
end

-- Get current map
function API.Game.GetMap()
    if Utility.IsValid(API.CurrentMap) then
        return API.CurrentMap
    end
    API.CurrentMap = CurrentRoom:FindFirstChildOfClass('Model')
    return API.CurrentMap
end

-- Get players folder
function API.Game.GetPlayersFolder()
    return InGamePlayers
end

-- Get info folder
function API.Game.GetInfoFolder()
    return InfoFolder
end

-- Get all info data objects
function API.Game.GetInfoData()
    return API.InfoData
end

-- Get specific info value object by name
function API.Game.GetInfoValueObject(name)
    if not name then return end
    
    local searchName = string.lower(name)
    for key, valueObject in pairs(API.InfoData) do
        if string.find(string.lower(key), searchName, 1, true) then
            return valueObject
        end
    end
    return
end

-- Get value from info object
function API.Game.GetInfoValue(valueObject)
    return valueObject.Value
end

-- Get current game state
function API.Game.GetGameState()
    if InfoFolder.Voting.Value then
        return 'Voting'
    elseif InfoFolder.FloorActive.Value then
        return 'FloorActive'
    else
        return 'Intermission'
    end
end

-- --- GENERATOR FUNCTIONS ---

-- Check if generator is possessed by Connie
function API.Generators.IsPossessed(generator)
    local stats = generator:FindFirstChild('Stats')
    return stats and stats.Connie.Value or false
end

-- Check if generator is default (single)
function API.Generators.IsDefault(generator)
    return generator and generator:GetAttribute('MachineFamily') == 'SINGLE' or false
end

-- Check if generator is dual
function API.Generators.IsDual(generator)
    return not API.Generators.IsDefault(generator)
end

-- Get generator type
function API.Generators.GetType(generator)
    return API.Generators.IsDefault(generator) and 'Default' or 'Dual'
end

-- Get minigame type(s)
function API.Generators.GetMinigameType(generator)
    if not generator then return nil end
    
    if API.Generators.IsDefault(generator) then
        return generator:GetAttribute('MinigameType')
    else
        return {
            ['1'] = generator:GetAttribute('MinigameType'),
            ['2'] = generator:GetAttribute('Prompt2MinigameType')
        }
    end
end

-- Get completed generators count
function API.Generators.GetCompleted()
    return InfoFolder.GeneratorsCompleted.Value
end

-- Get required generators count
function API.Generators.GetRequired()
    return InfoFolder.RequiredGenerators.Value
end

-- Get remaining generators
function API.Generators.GetRemaining()
    return API.Generators.GetRequired() - API.Generators.GetCompleted()
end

-- Check if this is the last generator
function API.Generators.IsLast()
    return API.Generators.GetRemaining() == 1
end

-- Get progress as decimal
function API.Generators.GetTotalProgressDecimal()
    return API.Generators.GetCompleted() / API.Generators.GetTotal()
end

-- Get progress as percentage
function API.Generators.GetTotalProgressPercent()
    return API.Generators.GetProgressDecimal() * 100
end

-- Get all generators
function API.Generators.GetAll()
    if not API.Game.GetMap() then return {} end
    
    local generatorsFolder = API.Game.GetMap():FindFirstChild('Generators')
    return generatorsFolder and generatorsFolder:GetChildren() or {}
end

-- Check if generator is completed
function API.Generators.IsCompleted(generator)
    local stats = generator:FindFirstChild('Stats')
    return stats and stats.Completed.Value or false
end

-- Check if generator is available
function API.Generators.IsAvailable(generator)
    local stats = generator and generator:FindFirstChild('Stats')
    if not stats then return false end
    
    if API.Generators.IsDual(generator) then
        return stats.ActivePlayer.Value == nil and stats.ActivePlayer2.Value == nil
    end
    return stats.ActivePlayer.Value == nil
end

-- Check if generator is uncompleted
function API.Generators.IsUncompleted(generator)
    return not API.Generators.IsCompleted(generator)
end

-- Check if generator is unavailable
function API.Generators.IsUnavailable(generator)
    return not API.Generators.IsAvailable(generator)
end

-- Get any completed generator
function API.Generators.GetAnyCompleted()
    for _, generator in API.Generators.GetAll() do
        if API.Generators.IsCompleted(generator) then
            return generator
        end
    end
end

-- Get any uncompleted generator
function API.Generators.GetAnyUncompleted()
    for _, generator in API.Generators.GetAll() do
        if API.Generators.IsUncompleted(generator) then
            return generator
        end
    end
end

-- Get any available generator
function API.Generators.GetAnyAvailable()
    for _, generator in API.Generators.GetAll() do
        if API.Generators.IsAvailable(generator) then
            return generator
        end
    end
end

-- Get any unavailable generator
function API.Generators.GetAnyUnavailable()
    for _, generator in API.Generators.GetAll() do
        if API.Generators.IsAvailable(generator) then
            return generator
        end
    end
end

-- Get closest generator
function API.Generators.GetClosest()
    return Utility.GetClosest(API.Generators.GetAll())
end

-- Get current progress amount
function API.Generators.GetCurrentAmount(generator)
    local stats = generator:FindFirstChild('Stats')
    return stats and stats.CurrentAmount.Value or 0
end

-- Get required amount
function API.Generators.GetRequiredAmount(generator)
    local stats = generator:FindFirstChild('Stats')
    return stats and stats.RequiredAmount.Value or 0
end

-- Get generator progress
function API.Generators.GetProgress(generator)
    return API.Generators.GetCurrentAmount(generator) / 
           API.Generators.GetRequiredAmount(generator)
end

-- --- PLAYER FUNCTIONS ---

-- Get all players
function API.Players.GetAll()
    return Players:GetPlayers()
end

-- Get local player
function API.Players.GetLocal()
    return Utility.LocalPlayer
end

-- Get local character
function API.Players.GetLocalCharacter()
    return Utility.LocalCharacter
end

-- Get player's character
function API.Players.GetCharacter(player)
    return player.Character
end

-- Get player's health
function API.Players.GetHealth(player)
    local character = API.Players.GetCharacter(player)
    if character then
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if humanoid then
            return humanoid.Health
        end
    end
    return 0
end

-- Check if player is alive
function API.Players.IsAlive(player)
    if InGamePlayers:FindFirstChild(player.Name) then
        return true
    end
    return false
end

-- Check if player is dead
function API.Players.IsDead(player)
    return not API.Players.IsAlive(player)
end

-- Get all alive players
function API.Players.GetAlive()
    local alive = {}
    for _, player in API.Players.GetAll() do
        if API.Players.IsAlive(player) then
            table.insert(alive, player)
        end
    end
    return alive
end

-- Get all dead players
function API.Players.GetDead()
    local dead = {}
    for _, player in API.Players.GetAll() do
        if API.Players.IsDead(player) then
            table.insert(dead, player)
        end
    end
    return dead
end

-- Get all alive characters
function API.Players.GetAliveCharacters()
    return InGamePlayers:GetChildren()
end

-- Get closest player
function API.Players.GetClosest()
    return Players:GetPlayerFromCharacter(
        Utility.GetClosest(API.Players.GetAliveCharacters())
    )
end

-- Get player stats
function API.Players.GetStats(player)
    local character = API.Players.GetCharacter(player)
    return character and character:FindFirstChild('Stats')
end

-- Get current stamina
function API.Players.GetCurrentStamina(player)
    local stats = API.Players.GetStats(player)
    return stats and stats.CurrentStamina.Value or 0
end

-- Get max stamina
function API.Players.GetMaxStamina(player)
    local stats = API.Players.GetStats(player)
    return stats and stats.Stamina.Value or 100
end

-- Get remaining stamina
function API.Players.GetStaminaRemaining(player)
    return API.Players.GetMaxStamina() - API.Players.GetCurrentStamina()
end

-- Get player inventory
function API.Players.GetInventory(player)
    local character = API.Players.GetCharacter(player)
    if character then
        local inventory = character:FindFirstChild('Inventory')
        if inventory then
            local items = {}
            for _, item in inventory:GetChildren() do
                items[item.Name] = item.Value
            end
            return items
        end
    end
    return {}
end

-- Check if player is extracting
function API.Players.IsExtracting(player)
    local character = API.Players.GetCharacter(player)
    if character then
        local decoding = character:FindFirstChild('Decoding')
        if decoding then
            return decoding.Value ~= nil
        end
    end
    return false
end

-- --- TWISTED (ENEMY) FUNCTIONS ---

-- Get all twisteds
function API.Twisteds.GetAll()
    if not API.Game.GetMap() then return {} end
    
    local monstersFolder = API.Game.GetMap():FindFirstChild('Monsters')
    return monstersFolder and monstersFolder:GetChildren() or {}
end

-- Get closest twisted
function API.Twisteds.GetClosest()
    return Utility.GetClosest(API.Twisteds.GetAll())
end

-- --- ITEM FUNCTIONS ---

-- Get all items
function API.Items.GetAll()
    if not API.Game.GetMap() then return {} end
    
    local itemsFolder = API.Game.GetMap():FindFirstChild('Items')
    return itemsFolder and itemsFolder:GetChildren() or {}
end

-- Get closest item
function API.Items.GetClosest()
    return Utility.GetClosest(API.Items.GetAll())
end

-- --- MAP FUNCTIONS ---

-- Get elevator
function API.Map.GetElevator()
    return Elevator
end

-- Get fake elevator
function API.Map.GetFakeElevator()
    local map = API.Game.GetMap()
    if not map then return nil end
    
    local freeArea = map:FindFirstChild('FreeArea')
    return freeArea and freeArea:FindFirstChild('FakeElevator') or nil
end

return API