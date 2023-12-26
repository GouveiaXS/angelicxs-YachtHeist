QBcore = nil
local CD = Config.Cooldown

if Config.UseESX then
    ESX = exports["es_extended"]:getSharedObject()
    TriggerEvent('qs-core:getSharedObject', function(obj) QS = obj end)

    ESX.RegisterServerCallback('angelicxs-YachtHeist:PoliceAvailable:ESX',function(source,cb)
        local xPlayers = ESX.GetPlayers()
        local cops = 0

        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            for i = 1, #Config.LEOJobName do
                if xPlayer.job.name == Config.LEOJobName[i] then
                    cops = cops + 1
                end
            end
        end

        if cops >= Config.RequiredNumberLEO then
            cb(true)
        else
            cb(false)
        end	
    end)


elseif Config.UseQBCore then
    QBCore = exports['qb-core']:GetCoreObject()

    QBCore.Functions.CreateCallback('angelicxs-YachtHeist:PoliceAvailable:QBCore', function(source, cb)
        local cops = 0
        local players = QBCore.Functions.GetQBPlayers()
        for k, v in pairs(players) do
            for i = 1, #Config.LEOJobName do
                if v.PlayerData.job.name == Config.LEOJobName[i] then
                    cops = cops + 1
                end
            end
        end

        if cops >= Config.RequiredNumberLEO then
            cb(true)
        else
            cb(false)
        end	
    end)
end

RegisterNetEvent('angelicxs-YachtHeist:Server:TrolleyReward', function(Trolley, pos, coords, type)
	local src = source
	local Player = nil
    local item = type
    local Dist = #(pos - coords)
    local Number = 0
    local info = nil
    local string = nil

    if Dist <= 5 then 
        if Trolley == 'ch_prop_gold_bar_01a' then 
            Number = math.random(Config.GoldBarMin, Config.GoldBarMax)
            string = Config.Lang['goldBars']
        elseif Trolley == 'hei_prop_heist_cash_pile' then
            string = Config.Lang['markedBills']
            Number = math.random(Config.MarkedBillMinNumberAmount, Config.MarkedBillMaxNumberAmount)
            info = {worth = math.random(Config.MarkedBillMin, Config.MarkedBillMax)}
        end
        if Number > 0 then
            if Config.UseESX then
                Player = ESX.GetPlayerFromId(src)
                Player.addInventoryItem(type, Number*info.worth, false)
            elseif Config.UseQBCore then
                Player = QBCore.Functions.GetPlayer(src)
                Player.Functions.AddItem(type, Number, false, info)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[type], 'add')
                if Trolley == 'ch_prop_gold_bar_01a' then 
                    TriggerEvent('qb-log:server:CreateLog', 'bankrobbery', 'Yacht Heist', 'green', 'Goldbars Received:\n'..Number..'\n**Person**:\n'..GetPlayerName(src))
                elseif Trolley == 'hei_prop_heist_cash_pile' then 
                    TriggerEvent('qb-log:server:CreateLog', 'bankrobbery', 'Yacht Heist', 'green', 'Marked Bills Received:\n'..Number..' worth $'..info.worth..'\n**Person**:\n'..GetPlayerName(src))
                end
            end
            TriggerClientEvent('angelicxs-YachtHeist:Notify', src, Config.Lang['gained'] .. Number .. string, Config.LangType['success'])
        else
            TriggerEvent('angelicxs-YachtHeist:ThatIsAThing', src)
        end
    else
        TriggerEvent('angelicxs-YachtHeist:ThatIsAThing', src)
    end
end)

RegisterNetEvent('angelicxs-YachtHeist:Server:BonusLoot', function(name)
	local src = source
	local Player = nil
    local item = Config.RareLootItem

    if name == "YachtRareSpot" then
        local chance = math.random(1,100)
        if chance <= Config.RareLootChance then
            if Config.UseESX then
                Player = ESX.GetPlayerFromId(src)
                Player.addInventoryItem(item, 1)
            elseif Config.UseQBCore then
                Player = QBCore.Functions.GetPlayer(src)
                Player.Functions.AddItem(item, 1)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[type], 'add')
                TriggerEvent('qb-log:server:CreateLog', 'bankrobbery', 'Yacht Heist', 'green', 'Rare Loot Received: '..item..'\n**Person**:\n'..GetPlayerName(src))
            end
            TriggerClientEvent('angelicxs-YachtHeist:Notify', src, Config.Lang['gained'] .. Config.RareLootItem, Config.LangType['success'])
        else
            TriggerClientEvent('angelicxs-YachtHeist:Notify', src, Config.Lang['missRare'], Config.LangType['info'])
        end
    elseif name == 'Bonus' then
        generalloot(src)
    else
        TriggerEvent('angelicxs-YachtHeist:ThatIsAThing', src)
        return
    end
end)

function generalloot(src)
    local List = Config.BonusLootItems
    local Number = 0
    math.random()
    local Selection = math.random(1, #List)
    for i = 1, #List do
        local reward = List[i]
        Number = Number + 1
        if Number == Selection then
            Number = 0
            if Config.UseESX then
                local xPlayer = ESX.GetPlayerFromId(src)
                xPlayer.addInventoryItem(reward.name, reward.amount)
            elseif Config.UseQBCore then
                local Player = QBCore.Functions.GetPlayer(src)
                Player.Functions.AddItem(reward.name, reward.amount)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[reward.name], 'add')
                TriggerEvent('qb-log:server:CreateLog', 'bankrobbery', 'Yacht Heist', 'green', 'Bonus Loot Received:\n'..reward.amount..' Item: '..reward.name..'\n**Person**:\n'..GetPlayerName(src))
            end
            TriggerClientEvent('angelicxs-YachtHeist:Notify',src, Config.Lang['gained']..reward.amount..' '..reward.name, Config.LangType['success'])
            break
        end
    end
end


--- Guard Spawner

RegisterNetEvent('angelicxs-YachtHeist:Server:Guards', function()
    for i = 1, #Config.GuardLocation do
        local Guard = Config.GuardLocation[i]
        local type = GuardSelector(Config.GuardType)
        local weapon = GuardSelector(Config.GuardWeapon)
        Guard = CreatePed(4, type, Config.GuardLocation[i].x, Config.GuardLocation[i].y, Config.GuardLocation[i].z, Config.GuardLocation[i].w, true, true)
        SetPedArmour(Guard, Config.GuardArmour)
        GiveWeaponToPed(Guard, weapon, 500)
        Wait(1000)
        CreateThread(function()
            while true do
                if CD == 0 then
                    if DoesEntityExist(Guard) then
                        DeleteEntity(Guard)
                        break
                    else
                        break
                    end
                end
                Wait(30000)
            end
        end)
    end
end)

function GuardSelector(Options)
    local List = Options
    local Number = 0
    math.random()
    local Selection = math.random(1, #List)
    for i = 1, #List do
        Number = Number + 1
        if Number == Selection then
            return List[i]
        end
    end
end

-- CoolDown

RegisterServerEvent('angelicxs-YachtHeist:Server:Counter',function()
    CD = Config.Cooldown
    TriggerClientEvent('angelicxs-YachtHeist:GlobalJobSync', -1)
    TriggerClientEvent('angelicxs-YachtHeist:Client:EngineLocations', -1)
    TriggerEvent('angelicxs-YachtHeist:Server:Guards')
    while true do
        CD = CD - 1
        Wait(60*1000)
        if CD <=0 then
            CD = 0
            break
        end
    end
    TriggerClientEvent('angelicxs-YachtHeist:Reset', -1, 'ok')
end)

-- Syncs
RegisterServerEvent('angelicxs-YachtHeist:Server:GlobalJobSync', function(status)
    TriggerClientEvent('angelicxs-YachtHeist:Client:GlobalJobSync', -1, status)
end)

RegisterServerEvent('angelicxs-YachtHeist:Server:ThirdEyeSync', function(name)
    TriggerClientEvent('angelicxs-YachtHeist:Client:ThirdEyeSync', -1, name)
end)

RegisterServerEvent('angelicxs-YachtHeist:Server:StatusSync', function(variable, status, trolly)
    TriggerClientEvent('angelicxs-YachtHeist:Client:StatusSync', -1, variable, status, trolly)
end)

RegisterServerEvent('angelicxs-YachtHeist:Server:EngineSync', function(name, disabled)
    TriggerClientEvent('angelicxs-YachtHeist:Client:EngineSync', -1, name, disabled)
end)

RegisterServerEvent('angelicxs-YachtHeist:Server:TrolleySync', function(loc, k, model)
    TriggerClientEvent('angelicxs-YachtHeist:Client:TrolleySync', -1, loc, k, model)
end)

RegisterServerEvent('angelicxs-YachtHeist:Server:BonusLootSync', function(k)
    TriggerClientEvent('angelicxs-YachtHeist:Client:BonusLootSync', -1, k)
end)

RegisterNetEvent('angelicxs-YachtHeist:server:EngineWine', function(pos)
    TriggerClientEvent('angelicxs-YachtHeist:client:EngineWine', -1, pos)
end)

-- Exploit Trigger
RegisterServerEvent('angelicxs-YachtHeist:ThatIsAThing', function(server)
    if server ~= nil then
        DropPlayer(server, "Go hack somewhere else.")
    end
    DropPlayer(source, "Go hack somewhere else.")
    Print("\n\n\n\nWARNING WARNING WARNING\nPlayer ID "..tostring(source)"/"..tostring(server).." was kicked for attempting to exploit angelicxs-YachtHeist. It is recommended you ban them.\nnWARNING WARNING WARNING\n\n\n\n")
end)
