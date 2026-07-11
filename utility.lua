local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Utils = {}

-- Checks if an NPC is an anomaly
function Utils.isAnomaly(npc)
    if not npc then return false end
    if npc:GetAttribute("Fake") == true or npc:GetAttribute("Fake") == "true" then return true end
    if npc:GetAttribute("Skinwalker") == true or npc:GetAttribute("Skinwalker") == "true" then return true end
    if CollectionService:HasTag(npc, "Skinwalker") or CollectionService:HasTag(npc, "SkinwalkerMonster") or CollectionService:HasTag(npc, "GhostAnomaly") then return true end
    local nameLower = npc.Name:lower()
    if nameLower:find("monster") or nameLower:find("ghost") or nameLower:find("anomaly") then return true end
    return false
end

-- Checks if an NPC is a valid patient
function Utils.isPatient(npc)
    if not npc then return false end
    if npc:GetAttribute("IsPatient") == true or npc:GetAttribute("IsPatient") == "true" then return true end
    if CollectionService:HasTag(npc, "ActivePatient") then return true end
    return false
end

-- Universal Speed Exploit
function Utils.setSpeed(speed)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speed end
end

return Utils
