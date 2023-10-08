ESX = nil
QBcore = nil
PlayerJob = nil
PlayerGrade = nil

local isLawEnforcement = false
local StartNPC
local PedSpawned = false
local GlobalJob = false
local EngineDisabled = 0
local PAlert = false
local xSound = exports.xsound
local EngineData = {
    E1 = {coord = vector3(-2042.64, -1035.6, 2.48), text = vector3(-2040.32, -1036.54, 2.59), active = false},
    E2 = {coord = vector3(-2040.72, -1028.62, 2.23), text = vector3(-2037.9, -1029.63, 2.58), active = false},
    E3 = {coord = vector3(-2033.61, -1031.0, 2.58), text = vector3(-2030.55, -1032.09, 2.56), active = false},
    E4 = {coord = vector3(-2035.83, -1037.88, 2.17), text = vector3(-2032.85, -1038.91, 2.56), active = false},
}


local RareLoot = false
local Console = vector3(-2068.78, -1022.93, 3.06)
local TrollyUp = false
local Trolley1 = nil
local Trolley2 = nil
local trolleys = {
    [1] = {
        coords = vector4(-2051.54, -1025.68, 7.97, 251.63),
        active = false,
        model = nil
    },
    [2] = {
        coords = vector4(-2055.65, -1031.03, 7.97, 224.24),
        active = false,
        model = nil
    },
},

RegisterNetEvent('angelicxs-YachtHeist:Notify', function(message, type)
	if Config.UseCustomNotify then
        TriggerEvent('angelicxs-YachtHeist:CustomNotify',message, type)
	elseif Config.UseESX then
		ESX.ShowNotification(message)
	elseif Config.UseQBCore then
		QBCore.Functions.Notify(message, type)
	end
end)

CreateThread(function()
    if Config.UseESX then
        ESX = exports["es_extended"]:getSharedObject()
	while not ESX.IsPlayerLoaded() do
            Wait(100)
        end
    
        local playerData = ESX.GetPlayerData()
        CreateThread(function()
            while true do
                if playerData ~= nil then
                    PlayerJob = playerData.job.name
                    PlayerGrade = playerData.job.grade
                    isLawEnforcement = LawEnforcement()
                    break
                end
                Wait(100)
            end
        end)
        RegisterNetEvent('esx:setJob', function(job)
            PlayerJob = job.name
            PlayerGrade = job.grade
            isLawEnforcement = LawEnforcement()
        end)

    elseif Config.UseQBCore then

        QBCore = exports['qb-core']:GetCoreObject()
        
        CreateThread(function ()
			while true do
                local playerData = QBCore.Functions.GetPlayerData()
				if playerData.citizenid ~= nil then
					PlayerJob = playerData.job.name
					PlayerGrade = playerData.job.grade.level
                    isLawEnforcement = LawEnforcement()
					break
				end
				Wait(100)
			end
		end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
            PlayerJob = job.name
            PlayerGrade = job.grade.level
            isLawEnforcement = LawEnforcement()
        end)
    end
    
    if Config.StartBlip then
		local blip = AddBlipForCoord(Config.StartPed.x,Config.StartPed.y,Config.StartPed.z)
		SetBlipSprite(blip, Config.StartBlipIcon)
		SetBlipColour(blip, Config.StartBlipColour)
		SetBlipScale(blip, 0.7)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(Config.StartBlipText)
		EndTextCommandSetBlipName(blip)
	end
    if Config.UseThirdEye then
        if Config.ThirdEyeName == 'ox_target' then
            local ox_options2 = {
                event = 'angelicxs-YachtHeist:ReleaseTrolly',
                icon = 'fas fa-terminal',
                label = Config.Lang['ReleaseTrolly'],
                temp = 'trap',
                canInteract = function()
                    return TrollyUp
                end,
            },
            exports.ox_target:addBoxZone({
                coords = Console,
                size = vec3(3, 2, 3),
                rotation = 74,
                debug = drawZones,
                options = ox_options2,
            })
            for Engine, Data in pairs (EngineData) do 
                local ox_options = {
                    event = 'angelicxs-YachtHeist:DisableEngine',
                    icon = 'fas fa-engine',
                    label = Config.Lang['EngineDisable'],
                    engine = Engine,
                    canInteract = function()
                        return Data.active
                    end,
                },
                exports.ox_target:addBoxZone({
                    coords = Data.coord,
                    size = vec3(5, 4, 3),
                    rotation = 69,
                    debug = drawZones,
                    options = ox_options,
                })
            end
            for k, Data in pairs(trolleys) do 
                exports.ox_target:addBoxZone({
                    coords = vector3(Data.coords.x, Data.coords.y, Data.coords.z),
                    size = vec3(0.9, 1.1, 2.5),
                    rotation = Data.coords.w,
                    debug = drawZones,
                    options = {
                        {
                            name = 'Trolley'..k,
                            event = 'angelicxs-YachtHeist:LootTrolly',
                            icon = 'fas fa-hand-paper',
                            label = Config.Lang['lootTrolly'],
                            canInteract = function()
                                return Data.active
                            end,
                        }
                    }
                })
            end
            for Number, Data in pairs (Config.BonusLootSpots) do 
                local ox_options = {
                    icon = 'fas fa-engine',
                    label = Config.Lang['lootTrolly'],
                    canInteract = function()
                        return Data.active
                    end,
                    onSelect = function()
                        BonusLoot(Number)
                    end,
                },
                exports.ox_target:addBoxZone({
                    coords = Data.coord,
                    size = vec3(1.5, 1.5, 3),
                    rotation = 0,
                    debug = drawZones,
                    options = ox_options,
                })
            end
            exports.ox_target:addBoxZone({
                coords = Config.RareLootSpot,
                size = vec3(1.5, 1.5, 3),
                rotation = 0,
                debug = drawZones,
                options = {
                    {
                        name = 'YachtRareSpot',
                        icon = 'fas fa-hand',
                        label = Config.Lang['lootTrolly'],
                        canInteract = function()
                            return RareLoot
                        end,
                        onSelect = function()
                            BonusLoot("YachtRareSpot")
                        end,
                    }
                }
            })
        else
            for Engine, Data in pairs (EngineData) do 
                exports[Config.ThirdEyeName]:AddBoxZone('YachtEngine'..Engine, Data.coord, 5, 4, {
                    name='YachtEngine'..Engine,
                    heading = 69.0,
                    debugPoly=false,
                    minZ = 1.58,
                    maxZ = 4.56
                }, {
                    options = {
                        {
                        event = 'angelicxs-YachtHeist:DisableEngine',
                        icon = 'fas fa-engine',
                        label = Config.Lang['EngineDisable'],
                        engine = Engine,
                        canInteract = function()
                            return Data.active
                        end,
                        },
                    },
                    distance = 2.5
                })  
            end
            for Number, Data in pairs (Config.BonusLootSpots) do 
                local nameSpot = tostring(Data.coord)
                exports[Config.ThirdEyeName]:AddBoxZone(nameSpot, Data.coord, 1.5, 1.5, {
                    name = nameSpot,
                    heading = 0.0,
                    debugPoly=false,
                    minZ = Data.coord.z-1.5,
                    maxZ = Data.coord.z+1.5,
                    }, {
                    options = {
                        {
                        icon = 'fas fa-hand',
                        label = Config.Lang['lootTrolly'],
                        canInteract = function()
                            return Data.active
                        end,
                        action = function()
                            BonusLoot(Number)
                        end,
                        },
                    },
                    distance = 2.5
                })
            end
            for k, Data in pairs(trolleys) do 
                exports[Config.ThirdEyeName]:AddBoxZone('Trolley'..k, vector3(Data.coords.x, Data.coords.y, Data.coords.z), 0.9, 1.1, {  
                    name = 'Trolley'..k, 
                    heading = Data.coords.w,
                    debugPoly = false,
                    minZ = Data.coords.z-1,
                    maxZ = Data.coords.z+1.5,
                    }, {
                    options = { 
                        { 
                            type = 'client',
                            event = 'angelicxs-YachtHeist:LootTrolly',
                            icon = 'fas fa-hand-paper',
                            label = Config.Lang['lootTrolly'],
                            canInteract = function()
                                return Data.active
                            end,
                        }
                    },
                    distance = 2,
                })
            end
            exports[Config.ThirdEyeName]:AddBoxZone('YachtEngineConsole', Console, 3, 2, {
                name='YachtEngineConsole',
                heading = 74.0,
                debugPoly=false,
                minZ = 1.58,
                maxZ = 4.56
                }, {
                options = {
                    {
                    event = 'angelicxs-YachtHeist:ReleaseTrolly',
                    icon = 'fas fa-terminal',
                    label = Config.Lang['ReleaseTrolly'],
                    temp = 'trap',
                    canInteract = function()
                        return TrollyUp
                    end,
                    },
                },
                distance = 2.5
            })  
            exports[Config.ThirdEyeName]:AddBoxZone("YachtRareSpot", Config.RareLootSpot, 1.5, 1.5, {
                name= "YachtRareSpot",
                heading = 0.0,
                debugPoly=false,
                minZ = Config.RareLootSpot.z-1.5,
                maxZ = Config.RareLootSpot.z+1.5,
                }, {
                options = {
                    {
                        icon = 'fas fa-hand',
                        label = Config.Lang['lootTrolly'],
                        canInteract = function()
                            return RareLoot
                        end,
                        action = function()
                            BonusLoot("YachtRareSpot")
                        end,
                    },
                },
                distance = 2.5
            }) 
        end
    end
    if Config.Use3DText then
        while true do
            local Sleep = 2000
            local Player = PlayerPedId()
            local Pos = GetEntityCoords(Player)
            local Dist = #(Pos - vector3(Config.StartPed.x, Config.StartPed.y, Config.StartPed.z))
            if Dist <= 25 then
                Sleep = 500
                if Dist <= 3 then
                    Sleep = 0
                    DrawText3Ds(Config.StartPed.x, Config.StartPed.y, Config.StartPed.z, Config.Lang['request'])
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent('angelicxs-YachtHeist:RobberyCheck')
                    end
                end
            end
            Wait(Sleep)
        end
    end
end)

-- Starting NPC Spawn
CreateThread(function()
    while true do
        local Player = PlayerPedId()
        local Pos = GetEntityCoords(Player)
        local Dist = #(Pos - vector3(Config.StartPed.x, Config.StartPed.y, Config.StartPed.z))
        if Dist <= 50 and not PedSpawned then
            TriggerEvent('angelicxs-YachtHeist:SpawnNPC',Config.StartPed,Config.StartModel)
            PedSpawned = true
        elseif DoesEntityExist(StartNPC) and PedSpawned then
            local Dist2 = #(Pos - GetEntityCoords(StartNPC))
            if Dist2 > 50 then
                DeleteEntity(StartNPC)
                PedSpawned = false
                if Config.UseThirdEye then
                    if Config.ThirdEyeName ~= 'ox_target' then
                        exports[Config.ThirdEyeName]:RemoveZone('YachtNPC')
                    end
                end
            end
        end
        Wait(2000)
    end
end)

RegisterNetEvent('angelicxs-YachtHeist:SpawnNPC',function(coords,model)
    local hash = HashGrabber(model)
    StartNPC = CreatePed(3, hash, coords.x, coords.y, (coords.z-1), coords.w, false, false)
    FreezeEntityPosition(StartNPC, true)
    SetEntityInvincible(StartNPC, true)
    SetBlockingOfNonTemporaryEvents(StartNPC, true)
    TaskStartScenarioInPlace(StartNPC,'WORLD_HUMAN_STAND_IMPATIENT', 0, false)
    SetModelAsNoLongerNeeded(model)
    if Config.UseThirdEye then
        if Config.ThirdEyeName == 'ox_target' then
            local options = {
                {
                    name = 'YachtNPC',
                    event = 'angelicxs-YachtHeist:RobberyCheck',
                    icon = 'fas fa-ship',
                    label = Config.Lang['AskJob'],
                },
            }
            exports.ox_target:addLocalEntity(StartNPC, options)
        else
            exports[Config.ThirdEyeName]:AddEntityZone('YachtNPC', StartNPC, {
                name="YachtNPC",
                debugPoly=false,
                useZ = true
                }, {
                options = {
                    {
                    event = 'angelicxs-YachtHeist:RobberyCheck',
                    icon = 'fas fa-ship',
                    label = Config.Lang['AskJob'],
                    },
                    
                },
                distance = 2
            })        
        end
    end
end)

RegisterNetEvent('angelicxs-YachtHeist:RobberyCheck', function()
    if not GlobalJob then
        if Config.RequireMinimumLEO then
            local StartRobbery = false
            if Config.UseESX then
                ESX.TriggerServerCallback('angelicxs-YachtHeist:PoliceAvailable:ESX', function(cb)
                    StartRobbery = cb
                end)                                    
            elseif Config.UseQBCore then
                QBCore.Functions.TriggerCallback('angelicxs-YachtHeist:PoliceAvailable:QBCore', function(cb)
                    StartRobbery = cb
                end)
            end
            Wait(1000)

            if StartRobbery then
                GlobalJob = true
                TriggerServerEvent('angelicxs-YachtHeist:Server:Counter')
                TriggerEvent('angelicxs-YachtHeist:Notify', Config.Lang['startHeist'], Config.LangType['info'])
            else
                TriggerEvent('angelicxs-YachtHeist:Notify', Config.Lang['mincops'], Config.LangType['error'])
            end
        else
            GlobalJob = true
            TriggerServerEvent('angelicxs-YachtHeist:Server:Counter')
            TriggerEvent('angelicxs-YachtHeist:Notify', Config.Lang['startHeist'], Config.LangType['info'])
        end
    else
        TriggerEvent('angelicxs-YachtHeist:Notify', Config.Lang['working'], Config.LangType['error'])
    end
end)

RegisterNetEvent('angelicxs-YachtHeist:GlobalJobSync', function()
    GlobalJob = true
    for Engine, Data in pairs (EngineData) do 
        Data.active = true
    end
    while GlobalJob do
        TriggerServerEvent('angelicxs-YachtHeist:Server:GlobalJobSync', true)
        if not GlobalJob then
            break
        end
        Wait(3000)
    end
    TriggerServerEvent('angelicxs-YachtHeist:Server:GlobalJobSync', false)
end)

RegisterNetEvent('angelicxs-YachtHeist:Client:GlobalJobSync', function(status)
    if status then
        GlobalJob = true
    else
        GlobalJob = false
    end
end)

RegisterNetEvent('angelicxs-YachtHeist:Client:EngineLocations', function()
    Wait(1000)
    if Config.Use3DText then
        for Engine, Data in pairs (EngineData) do 
            CreateThread(function()
                while Data.active do 
                    local Sleep = 2000
                    local Pos = GetEntityCoords(PlayerPedId())
                    local Dist = #(Pos - Data.text)
                    if Dist <= 20 then
                        Sleep = 500
                        if Dist <= 3 then
                            Sleep = 0
                            DrawText3Ds(Data.text.x, Data.text.y, Data.text.z, Config.Lang['EngineDisable3D'])
                            if IsControlJustReleased(0, 38) then
                                local data = {}
                                data.engine = Engine
                                TriggerEvent('angelicxs-YachtHeist:DisableEngine', data)
                            end
                        end
                    end 
                    Wait(Sleep)
                end
            end)
        end
    end
end)

RegisterNetEvent('angelicxs-YachtHeist:DisableEngine', function(data)
    if not PAlert then
        TriggerEvent('angelicxs-YachtHeist:PoliceAlert',GetEntityCoords(PlayerPedId()))
        TriggerServerEvent('angelicxs-YachtHeist:Server:StatusSync', 1, true)
        PAlert = true
    end
    if data.engine == nil then return end
    exports['ps-ui']:Thermite(function(success)
        if success then
            local Destroyed = EngineDisabled + 1
            TriggerServerEvent('angelicxs-YachtHeist:Server:EngineSync',data.engine, Destroyed)
	        if Destroyed == 4 then
                TriggerEvent('angelicxs-YachtHeist:Notify', Config.Lang['activeConsole'], Config.LangType['info'])
            end
        else
            TriggerServerEvent('angelicxs-YachtHeist:server:EngineWine', GetEntityCoords(PlayerPedId()))
        end
    end, 20, 5+EngineDisabled, 3) -- Time, Gridsize (5, 6, 7, 8, 9, 10), IncorrectBlocks
end)

RegisterNetEvent('angelicxs-YachtHeist:Client:StatusSync', function(variable, status, trolly)
    if variable == 1 then
        PAlert = status
    elseif variable == 2 then
        TrollyUp = status
    elseif variable == 3 then
        RareLoot = status
    elseif variable == 4 then
        trolleys[trolly]['active'] = status
    end
end)

RegisterNetEvent('angelicxs-YachtHeist:client:EngineWine', function (pos)
    xSound:PlayUrlPos("sputter","https://www.youtube.com/watch?v=Iuy9FkFgnOA&ab_channel=SoundLibrary",0.25,pos, false)
    xSound:Distance("sputter",100)
end)

RegisterNetEvent('angelicxs-YachtHeist:Client:EngineSync', function(name, disabled)
    if name == nil then return end
    EngineData[name]['active'] = false
    EngineDisabled = disabled
    TriggerEvent('angelicxs-YachtHeist:Console')
end)

RegisterNetEvent('angelicxs-YachtHeist:Console', function()

    if EngineDisabled == 4 then
        TriggerServerEvent('angelicxs-YachtHeist:Server:StatusSync', 2, true)
        TriggerServerEvent('angelicxs-YachtHeist:Server:StatusSync', 3, true)
        Wait(1000)
        if Config.Use3DText then
            while true do 
                local Sleep = 2000
                local Player = PlayerPedId()
                local Pos = GetEntityCoords(Player)
                local Dist = #(Pos - Console)
                if Dist <= 25 then
                    Sleep = 500
                    if Dist <= 3 then
                        Sleep = 0
                        DrawText3Ds(Console.x,Console.y,Console.z, Config.Lang['requestTrolley'])
                        if IsControlJustReleased(0, 38) then
                            local data = {temp = 'trap'}
                            TriggerEvent('angelicxs-YachtHeist:ReleaseTrolly', data)
                            break
                        end
                    end
                end
                if not GlobalJob or not TrollyUp then
                    break
                end
                Wait(Sleep)
            end
        end
    end
end)

RegisterNetEvent('angelicxs-YachtHeist:ReleaseTrolly', function(data)
    if data.temp ~= 'trap' then
        TriggerServerEvent('angelicxs-YachtHeist:ThatIsAThing')
    else
        if TrollyUp then
            TriggerEvent('angelicxs-YachtHeist:Notify', Config.Lang['ReleaseedTrolly'], Config.LangType['info'])
            TriggerServerEvent('angelicxs-YachtHeist:Server:StatusSync', 2, false)
            for k,v in pairs(trolleys) do
                local loc = v.coords
                local TrolleyLoot = math.random(1,100)
                if TrolleyLoot <= Config.GoldBarChance then 
                    TriggerServerEvent('angelicxs-YachtHeist:Server:TrolleySync', loc, k, 2007413986)  -- Gold Bars
                else 
                    TriggerServerEvent('angelicxs-YachtHeist:Server:TrolleySync', loc, k, 269934519)  -- Cash
                end
            end
        else
            TriggerEvent('angelicxs-YachtHeist:Notify', Config.Lang['allDown'], Config.LangType['error'])
        end
    end
end)

RegisterNetEvent('angelicxs-YachtHeist:Client:TrolleySync', function(loc, k, model)
    if not loc or not k or not model then
        TriggerServerEvent('angelicxs-YachtHeist:ThatIsAThing')
    end
	loadModel(model)
    if k == 1 then
        Trolley1 = CreateObject(model, loc.x, loc.y, loc.z, 1, 0, 0)
        SetEntityHeading(Trolley1, loc.w)
        trolleys[k]['model'] = model
        TrollyLoot3D(k)
    elseif k == 2 then
        Trolley2 = CreateObject(model, loc.x, loc.y, loc.z, 1, 0, 0)
        SetEntityHeading(Trolley2, loc.w)
        trolleys[k]['model'] = model
        TrollyLoot3D(k)
    else
        TriggerServerEvent('angelicxs-YachtHeist:ThatIsAThing')
        return
    end
	SetModelAsNoLongerNeeded(model)
    for Number, Data in pairs (Config.BonusLootSpots) do 
        Data.active = true
    end
    if Config.Use3DText then 
        for Number, Data in pairs (Config.BonusLootSpots) do 
            CreateThread(function()
                while Data.active do
                    local Sleep = 2000
                    local Player = PlayerPedId()
                    local Pos = GetEntityCoords(Player)
                    local Dist = #(Pos - Data.coord)
                    if Dist <= 20 then
                        Sleep = 500
                        if Dist <= 2 then
                            Sleep = 0
                            DrawText3Ds(Data.coord.x, Data.coord.y, Data.coord.z, Config.Lang['lootTrolly3d'])
                            if IsControlJustReleased(0, 38) then
                                BonusLoot(Number)
                            end
                        end
                    end 
                    if not Data.active then
                        break
                    end
                    Wait(Sleep)
                end
            end)
        end
        while RareLoot do
            local Sleep = 2000
            local Player = PlayerPedId()
            local Pos = GetEntityCoords(Player)
            local Dist = #(Pos - Config.RareLootSpot)
            if Dist <= 20 then
                Sleep = 500
                if Dist <= 3 then
                    Sleep = 0
                    DrawText3Ds(Config.RareLootSpot.x, Config.RareLootSpot.y, Config.RareLootSpot.z, Config.Lang['lootTrolly3d'])
                    if IsControlJustReleased(0, 38) then
                        BonusLoot('YachtRareSpot')
                    end
                end
            end 
            if not RareLoot then
                break
            end
            Wait(Sleep)
        end
    end
end)

RegisterNetEvent('angelicxs-YachtHeist:Client:BonusLootSync', function(name)
    if name == nil then return end
    Config.BonusLootSpots[name]['active'] = false
end)

RegisterNetEvent('angelicxs-YachtHeist:LootTrolly', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    for k,v in pairs(trolleys) do
        if not v.actve then
            local coords =  vector3(v.coords.x, v.coords.y, v.coords.z)
            local TrolleyDist = #(pos - coords)
            if TrolleyDist <= 2 then
                LocalPlayer.state:set('inv_busy', true, true) -- Busy
                TriggerServerEvent('angelicxs-YachtHeist:Server:StatusSync', 4, false, k)
                local pedRotation = vector3(0.0, 0.0, 0.0)
                local trollyModel = v.model
                local animDict = 'anim@heists@ornate_bank@grab_cash'
                local grabModel = nil
                local type = nil

                if trollyModel == 2007413986 then
                    grabModel = 'ch_prop_gold_bar_01a'
                    type = Config.GoldBarName
                else
                    grabModel = 'hei_prop_heist_cash_pile'
                    type = Config.MarkedBillName
                end

                loadAnimDict(animDict)
                loadModel('hei_p_m_bag_var22_arm_s')

                local sceneObject = GetClosestObjectOfType(coords, 2.0, trollyModel, 0, 0, 0)

                if IsEntityPlayingAnim(sceneObject, animDict, "cart_cash_dissapear", 3) then
                    return
                end
                SetEntityCollision(sceneObject, true, true)

                local bag = CreateObject(GetHashKey('hei_p_m_bag_var22_arm_s'), pos, true, false, false)

                while not NetworkHasControlOfEntity(sceneObject) do
                    Wait(1)
                    NetworkRequestControlOfEntity(sceneObject)
                end

                local scene1 = NetworkCreateSynchronisedScene(GetEntityCoords(sceneObject), GetEntityRotation(sceneObject), 2, true, false, 1065353216, 0, 1.3)
                NetworkAddPedToSynchronisedScene(ped, scene1, animDict, 'intro', 1.5, -4.0, 1, 16, 1148846080, 0)
                NetworkAddEntityToSynchronisedScene(bag, scene1, animDict, 'bag_intro', 4.0, -8.0, 1)

                local scene2 = NetworkCreateSynchronisedScene(GetEntityCoords(sceneObject), GetEntityRotation(sceneObject), 2, true, true, 1065353216, 0, 1.3)
                NetworkAddPedToSynchronisedScene(ped, scene2, animDict, 'grab', 1.5, -4.0, 1, 16, 1148846080, 0)
                NetworkAddEntityToSynchronisedScene(bag, scene2, animDict, 'bag_grab', 4.0, -8.0, 1)
                NetworkAddEntityToSynchronisedScene(sceneObject, scene2, animDict, 'cart_cash_dissapear', 4.0, -8.0, 1)

                local scene3 =  NetworkCreateSynchronisedScene(GetEntityCoords(sceneObject), GetEntityRotation(sceneObject), 2, true, false, 1065353216, 0, 1.3)
                NetworkAddPedToSynchronisedScene(ped, scene3, animDict, 'exit', 1.5, -4.0, 1, 16, 1148846080, 0)
                NetworkAddEntityToSynchronisedScene(bag, scene3, animDict, 'bag_exit', 4.0, -8.0, 1)

                NetworkStartSynchronisedScene(scene1)
                Wait(1750)
                TriggerEvent('angelicxs-YachtHeist:GrabTrolley', grabModel)
                NetworkStartSynchronisedScene(scene2)
                Wait(37000)
                NetworkStartSynchronisedScene(scene3)
                Wait(2000)

                local emptyobj = 769923921
                local newTrolly = CreateObject(emptyobj, coords, true, false, false)
                SetEntityRotation(newTrolly, 0, 0, GetEntityHeading(sceneObject), 1, 0)
                DeleteObject(sceneObject)
                DeleteEntity(sceneObject)
                DeleteObject(bag)
                TriggerServerEvent('angelicxs-YachtHeist:Server:TrolleyReward', grabModel, pos, coords, type)
                LocalPlayer.state:set('inv_busy', false, true) -- Not Busy
            end
        end
    end
end)

RegisterNetEvent('angelicxs-YachtHeist:GrabTrolley', function(grabModel)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local grabModel = GetHashKey(grabModel)

    loadModel(grabModel)
    local grabObject = CreateObject(grabModel, pos, true)

    FreezeEntityPosition(grabObject, true)
    SetEntityInvincible(grabObject, true)
    SetEntityNoCollisionEntity(grabObject, ped)
    SetEntityVisible(grabObject, false, false)
    AttachEntityToEntity(grabObject, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
    local Looting = GetGameTimer()

    CreateThread(function()
        while GetGameTimer() - Looting < 37000 do
            Wait(1)
            DisableControlAction(0, 73, true)
            if HasAnimEventFired(ped, GetHashKey('CASH_APPEAR')) then
                if not IsEntityVisible(grabObject) then
                    SetEntityVisible(grabObject, true, false)
                end
            end
            if HasAnimEventFired(ped, GetHashKey('RELEASE_CASH_DESTROY')) then
                if IsEntityVisible(grabObject) then
                    SetEntityVisible(grabObject, false, false)
                end
            end
        end
        DeleteObject(grabObject)
    end)
end)

RegisterNetEvent('angelicxs-YachtHeist:Reset', function(tolerance)
    if tolerance == 'ok' then
        GlobalJob = false
	    PAlert = false
        TrollyUp = false
        for Number, Data in pairs (Config.BonusLootSpots) do 
            Data.active = false
        end
        for Number, Data in pairs (trolleys) do 
            Data.active = false
        end
        for Engine, Data in pairs (EngineData) do 
            Data.active = false
        end
        RareLoot = false
        if DoesEntityExist(Trolley1) then
            DeleteEntity(Trolley1)
            DeleteObject(Trolley1)
        end
        if DoesEntityExist(Trolley2) then
            DeleteEntity(Trolley2)
            DeleteObject(Trolley2)
        end
        Wait(5000)
        GlobalJob = false
    else
        TriggerServerEvent('angelicxs-YachtHeist:ThatIsAThing')
    end
end)

-- Functions
function TrollyLoot3D(k)
    TriggerServerEvent('angelicxs-YachtHeist:Server:StatusSync', 4, true, k)
    if Config.Use3DText then
        Wait(1000)
        local TCoord = vector3(trolleys[k]['coords'].x, trolleys[k]['coords'].y, trolleys[k]['coords'].z)
	    CreateThread(function()
	        while true do
	            local ped = PlayerPedId()
	            local pos = GetEntityCoords(ped)
	            local Sleep = 2000
	            local TDist = #(pos - TCoord)
	            if TDist < 30 then 
	                Sleep = 500
	                if TDist < 5 then
	                    Sleep = 0
	                    if TDist < 2 then
	                        DrawText3Ds(trolleys[k]['coords'].x, trolleys[k]['coords'].y, trolleys[k]['coords'].z + 1, Config.Lang['lootTrolly3d'])
	                        if IsControlJustPressed(0, 38) then
	                            TriggerEvent("angelicxs-YachtHeist:LootTrolly")
	                        end
	                    end
	                end
	            end
	            if not GlobalJob or not trolleys[k]['active'] then
	                break
	            end
	            Wait(Sleep)
	        end
	    end)
    end
end

function BonusLoot(data)
    if data == "YachtRareSpot" then
        exports['ps-ui']:VarHack(function(success)
            if success then
                TriggerServerEvent('angelicxs-YachtHeist:Server:StatusSync', 3, false)
                LootAnim()
                Wait(5500)
                TriggerServerEvent('angelicxs-YachtHeist:Server:BonusLoot', data)
            end
        end, 2, 3) -- Number of Blocks, Time (seconds)
    else
        TriggerServerEvent('angelicxs-YachtHeist:Server:BonusLootSync', data)
        LootAnim()
        Wait(5500)
        TriggerServerEvent('angelicxs-YachtHeist:Server:BonusLoot', 'Bonus')
    end
end

function LootAnim()
    local Player = PlayerPedId()
    FreezeEntityPosition(Player, true)
    RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
        Wait(10)
    end
    TaskPlayAnim(Player,"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer",1.0, -1.0, -1, 49, 0, 0, 0, 0)
    Wait(5500)	
    ClearPedTasks(Player)
    FreezeEntityPosition(Player, false)
    RemoveAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
end

function LawEnforcement()
    for i = 1, #Config.LEOJobName do
        if PlayerJob == Config.LEOJobName[i] then
            return true
        end
    end
    return false
end

function HashGrabber(model)
    local hash = GetHashKey(model)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do
      Wait(10)
    end
    return hash
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.30, 0.30)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(0)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        GlobalJob = false
	    PAlert = false
        TrollyUp = false
        if DoesEntityExist(StartNPC) then
            DeleteEntity(StartNPC)
        end 
        for Number, Data in pairs (Config.BonusLootSpots) do 
            Data.active = false
        end
        for Number, Data in pairs (trolleys) do 
            Data.active = false
        end
        for Engine, Data in pairs (EngineData) do 
            Data.active = false
        end
        if DoesEntityExist(Trolley1) then
            DeleteEntity(Trolley1)
        end
        if DoesEntityExist(Trolley2) then
            DeleteEntity(Trolley2)
        end
    end
end)
