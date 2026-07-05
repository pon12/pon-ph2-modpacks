LogMessage("Loaded class script: BountyHunter.lua")

local gs = GetGameState()

local name = "BountyHunter"

local abilityTime = 10.0
local abilityCooldown = 40.0

local currentTarget
local targetPosition
local reward = 5000
local targetIsAlive
local targetRevealTime = 10.0


local function pingTarget()
    SetTimer(targetRevealTime, "BountyHunter_RevealTarget_Event", currentTarget)
    LogMessage("Function: pingTarget called")
end

ListenToEvent("BountyHunter_RevealTarget_Event", function(currentTarget)
    targetPosition = currentTarget:GetActorLocation()
    gs:SpawnLuaPingSV("BH_3.png", targetPosition)

    if targetIsAlive == true then
        LogMessage("BH_RevealTarget_Event: Target is Alive: " .. GetActorName(currentTarget))
        SetTimer(targetRevealTime, "BountyHunter_RevealTarget_Event", currentTarget)
    else
        LogMessage("BH_RevealTarget_Event: Target is not Alive: " .. GetActorName(currentTarget))
    end
end)


local function getRandomTarget(deadTarget)
    local possibleTargets = GetAllActorsOfClass("AI_Employee")
    
    if not possibleTargets or #possibleTargets == 0 then
        LogMessage("No AI targets found in the scene yet")
        targetIsAlive = false
        return
    end

    local deadTargetName = nil
    if deadTarget then
        deadTargetName = GetActorName(deadTarget)
        LogMessage("DEAD GUY: " .. deadTargetName)
    end

    for i = #possibleTargets, 1, -1 do
        local targetName = GetActorName(possibleTargets[i])
        if deadTargetName and targetName == deadTargetName then
            table.remove(possibleTargets, i)
            LogMessage("Removed dead target: " .. deadTargetName)
            break
        end
    end

    local possibleTargetCount = #possibleTargets
    LogMessage("Possible targets remaining: " .. possibleTargetCount)

    if possibleTargetCount < 1 then
        LogMessage("No valid targets alive")
        targetIsAlive = false
    else
        local randomInt = math.random(1, possibleTargetCount)
        currentTarget = possibleTargets[randomInt]
        targetIsAlive = true
        LogMessage("New Target: " .. GetActorName(currentTarget))
        pingTarget()
    end
end



ListenToEvent("PreReceiveDamage", function(targetActor, sourceActor, damage, damageType, canBeLethal)
    if targetIsAlive == true then
        if GetActorName(targetActor) == GetActorName(currentTarget) then
            if canBeLethal == true then
                if sourceActor.CustomClassString == name then
                    LogMessage("Target killed by BountyHunter")
                    targetIsAlive = false
                    gs.savedMoney = gs.savedMoney + reward
                    getRandomTarget(targetActor)
                else
                    LogMessage("Target dead (Not BH)")
                    targetIsAlive = false
                    getRandomTarget(targetActor)
                end
            end
        end
    else
        LogMessage("No Target Alive")
    end
end)


ListenToEvent("RoundStarted", function()
    LogMessage("Round started!")
    local allPlayers = GetPlayerChars()
    for i, player in pairs(allPlayers) do
        if player.CustomClassString == name then
            getRandomTarget()
            --LogMessage(GetActorName(player) .. "is BountyHunter")
        else
            --LogMessage(GetActorName(player) .. "is NOT BountyHunter")
        end
    end

end)


ListenToEvent("AbilityKeyPressed_OnClient", function(playerActor)
    if playerActor.CustomClassString == name then

        playerActor:StartAbilityCooldown(abilityTime)
        playerActor:AbilitySV()
        ShowUIText("BountyHunter_InvisibilityNotification", "You are Invisible", 0.45, 0.6, abilityTime, 20, {0.5, 0.8, 1.0, 1.0})

    end
end)


ListenToEvent("AbilitySV", function(playerActor)
    if playerActor.CustomClassString == name then
        --LogMessage("SERVER: Bountyhunter cloaking!")
		playerActor.preventShooting=true
        SetTimer(abilityTime, "BountyhunterUncloak", playerActor)
    end
end)

ListenToEvent("AbilityALL_OnClient", function(playerActor)
    if playerActor.CustomClassString == name then
        --LogMessage("ALL CLIENTS: Bountyhunter cloaking!")
	
        playerActor.Mesh:SetHiddenIngame(true)

		playerActor.FP_Arms:SetHiddenIngame(true)

        SetTimer(abilityTime, "BountyhunterUncloak_ALL", playerActor)
    end
end)

ListenToEvent("BountyhunterUncloak", function(playerActor)
	playerActor.preventShooting=false
    --LogMessage("SERVER: Bountyhunter visible again!")
end)

ListenToEvent("BountyhunterUncloak_ALL", function(playerActor)
    playerActor.Mesh:SetHiddenIngame(false)
	playerActor.FP_Arms:SetHiddenIngame(false)
    playerActor:StartAbilityCooldown(abilityCooldown)
    --LogMessage("ALL CLIENTS: Bountyhunter visible again!")
end)