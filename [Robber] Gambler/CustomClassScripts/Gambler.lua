LogMessage("Loaded class script: Gambler.lua")

local gs = GetGameState()

local name = "Gambler"

local abilityCooldown = 5.0

local arcadeReward = 6000

local gamblingAmount_1 = 5000
local gamblingAmount_2 = 10000
local gamblingAmount_3 = 20000
local gamblingAmount_AllIn_Min = 1

--WinChances X out of 10 (5 = 50%)
local gamblingChance_1 = 5
local gamblingChance_2 = 5
local gamblingChance_3 = 5
local gamblingChance_4 = 5

--Passive Ability
ListenToEvent("PlayerInteractedSV", function(targetActor, playerActor)
    if playerActor.CustomClassString == name then
        local interactedActor = GetActorClassName(targetActor)
        if interactedActor == "ATM_Arcade" then
            local VanillaCashPile = SphereOverlap(targetActor:GetActorLocation(), 50)
            for i, actor in ipairs(VanillaCashPile) do
                local moneyClassName = GetActorClassName(actor)
                --LogMessage(GetActorName(actor) .. " - ".. moneyClassName)
                if moneyClassName == "MoneyCashPile" then
                    local targetPosition = actor:GetActorLocation()
                    gs:LuaDestroyActor(actor)
                    local Cash = SpawnActor("MoneyCash", targetPosition)
                    Cash.moneyValue = arcadeReward
                end
            end
        end
    end
end)




-- CLIENT: Ability key pressed
ListenToEvent("AbilityKeyPressed_OnClient", function(playerActor)
    if playerActor.CustomClassString == name then
        --LogMessage("CLIENT: Gambler ability!")
        StartPieMenu(playerActor, {
            {Name = gamblingAmount_1 .."k",    Description = gamblingChance_1.."0% Winchance", Icon = "Gambler_1.png"},
            {Name = gamblingAmount_2.."k",   Description = gamblingChance_2.."0% Winchance", Icon = "Gambler_2.png"},
            {Name = gamblingAmount_3.."k",  Description = gamblingChance_3.."0% Winchance", Icon = "Gambler_3.png"},
            {Name = "All In",    Description = gamblingChance_4.."0% Winchance", Icon = "Gambler_4.png"},
            {Name = "Cancel", Description = "Cancel Ability", Icon ="Gambler_5.png"}
        })


    end
end)


ListenToEvent("PieMenuSelected_OnClient", function(playerActor, selectedIndex)
    if playerActor.CustomClassString == name then
        if selectedIndex == 0 then
            --LogMessage(gamblingAmount_1.."k selected")
            playerActor:SetReplicatedVar("gamblerSelected", "1")

            if playerActor.ActionComponent.moneyAmount >= gamblingAmount_1 then
                playerActor:StartAbilityCooldown(abilityCooldown)
                playerActor:AbilitySV()
            else
                --LogMessage("Not Enough Money")
                ShowUIText("Gambler_NEM_Notification", "Not Enough Money", 0.45, 0.6, 3, 20)
            end


        elseif selectedIndex == 1 then
            --LogMessage(gamblingAmount_2.."k selected")
            playerActor:SetReplicatedVar("gamblerSelected", "2")

            if playerActor.ActionComponent.moneyAmount >= gamblingAmount_2 then
                playerActor:StartAbilityCooldown(abilityCooldown)
                playerActor:AbilitySV()
            else
                --LogMessage("Not Enough Money")
                ShowUIText("Gambler_NEM_Notification", "Not Enough Money", 0.45, 0.6, 3, 20)
            end
        elseif selectedIndex == 2 then
            --LogMessage(gamblingAmount_3.."k selected")
            playerActor:SetReplicatedVar("gamblerSelected", "3")

            if playerActor.ActionComponent.moneyAmount >= gamblingAmount_3 then
                playerActor:StartAbilityCooldown(abilityCooldown)
                playerActor:AbilitySV()
            else
                --LogMessage("Not Enough Money")
                ShowUIText("Gambler_NEM_Notification", "Not Enough Money", 0.45, 0.6, 3, 20)
            end
        elseif selectedIndex == 3 then
            --LogMessage("All In selected")
            playerActor:SetReplicatedVar("gamblerSelected", "4")

            if playerActor.ActionComponent.moneyAmount >= gamblingAmount_AllIn_Min then
                playerActor:StartAbilityCooldown(abilityCooldown)
                playerActor:AbilitySV()
            else
                --LogMessage("Not Enough Money")
                ShowUIText("Gambler_NEM_Notification", "Not Enough Money", 0.45, 0.6, 3, 20)
            end


        elseif selectedIndex == 4 then
            --LogMessage("Cancel")
            playerActor:SetReplicatedVar("gamblerSelected", "0")
        end
    end
end)


--WIP
--[[
ListenToEvent("Gambler_Win_Event_OnClient", function(actor)
    local gamblerSelected = tonumber(actor:GetReplicatedVar("gamblerSelected"))
    local gamblingAmount
    if gamblerSelected == 1 then
        gamblingAmount = gamblingAmount_1
    elseif gamblerSelected == 2 then
        gamblingAmount = gamblingAmount_2
    elseif gamblerSelected == 3 then
        gamblingAmount = gamblingAmount_3
    elseif gamblerSelected == 4 then

    end


    ShowUIText("Gambler_Win_Notification", "You Won ".. gamblingAmount.."$", 0.45, 0.6, 3, 20)
end)
]]

-- SERVER: Ability execution
ListenToEvent("AbilitySV", function(playerActor)
    if playerActor.CustomClassString == name then
        local gamblerSelected = tonumber(playerActor:GetReplicatedVar("gamblerSelected"))
        --LogMessage("Gambler: " .. gamblerSelected)
        local result = math.random(1,10)
        --LogMessage(result)
        if gamblerSelected == 1 then
            if result <= gamblingChance_1 then
                --LogMessage("WIN")

                playerActor.ActionComponent.moneyAmount = playerActor.ActionComponent.moneyAmount + gamblingAmount_1
            else
                --LogMessage("LOSE")
                --ShowUIText("Gambler_Lose_Notification", "You Lost ".. gamblingAmount_1.."$", 0.45, 0.6, 3, 20)
                playerActor.ActionComponent.moneyAmount = playerActor.ActionComponent.moneyAmount - gamblingAmount_1
            end

        elseif gamblerSelected == 2 then
            if result <= gamblingChance_2 then
                --LogMessage("WIN")
                --ShowUIText("Gambler_Win_Notification", "You Won ".. gamblingAmount_2.."$", 0.45, 0.6, 3, 20)
                playerActor.ActionComponent.moneyAmount = playerActor.ActionComponent.moneyAmount + gamblingAmount_2
            else
                --LogMessage("LOSE")
                --ShowUIText("Gambler_Lose_Notification", "You Lost ".. gamblingAmount_2.."$", 0.45, 0.6, 3, 20)
                playerActor.ActionComponent.moneyAmount = playerActor.ActionComponent.moneyAmount - gamblingAmount_2
            end

        elseif gamblerSelected == 3 then
            if result <= gamblingChance_3 then
                --LogMessage("WIN")
                --ShowUIText("Gambler_Win_Notification", "You Won ".. gamblingAmount_3.."$", 0.45, 0.6, 3, 20)
                playerActor.ActionComponent.moneyAmount = playerActor.ActionComponent.moneyAmount + gamblingAmount_3
            else
                --LogMessage("LOSE")
                --ShowUIText("Gambler_Lose_Notification", "You Lost ".. gamblingAmount_3.."$", 0.45, 0.6, 3, 20)
                playerActor.ActionComponent.moneyAmount = playerActor.ActionComponent.moneyAmount - gamblingAmount_3
            end

        elseif gamblerSelected == 4 then
            local playerMoney = playerActor.ActionComponent.moneyAmount
            --LogMessage(playerMoney)

            if result <= gamblingChance_4 then
                --LogMessage("WIN")
                --ShowUIText("Gambler_Win_Notification", "You Won ".. playerMoney .."$", 0.45, 0.6, 3, 20)
                playerActor.ActionComponent.moneyAmount = playerActor.ActionComponent.moneyAmount + playerMoney
            else
                --LogMessage("LOSE")
                --ShowUIText("Gambler_Lose_Notification", "You Lost ".. playerMoney .."$", 0.45, 0.6, 3, 20)
                playerActor.ActionComponent.moneyAmount = playerActor.ActionComponent.moneyAmount - playerMoney
            end
        end
    end
end)



