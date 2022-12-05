----------------------------------------------------------------------
-- Thanks for supporting AngelicXS Scripts!							--
-- Support can be found at: https://discord.gg/tQYmqm4xNb			--
-- More paid scripts at: https://angelicxs.tebex.io/ 				--
-- More FREE scripts at: https://github.com/GouveiaXS/ 				--
----------------------------------------------------------------------
-- Model info: https://docs.fivem.net/docs/game-references/ped-models/
-- Blip info: https://docs.fivem.net/docs/game-references/blips/


Config = {}


Config.UseESX = false						-- Use ESX Framework
Config.UseQBCore = true					-- Use QBCore Framework (Ignored if Config.UseESX = true)

Config.UseCustomNotify = false				-- Use a custom notification script, must complete event below.

-- Only complete this event if Config.UseCustomNotify is true; mythic_notification provided as an example
RegisterNetEvent('angelicxs-YachtHeist:CustomNotify')
AddEventHandler('angelicxs-YachtHeist:CustomNotify', function(message, type)
    --exports.mythic_notify:SendAlert(type, message, 4000)
end)

-- Visual Preference
Config.Use3DText = false 					-- Use 3D text for NPC interactions; only turn to false if Config.UseThirdEye is turned on and IS working.
Config.UseThirdEye = true 					-- Enables using a third eye (third eye requires the following arguments debugPoly, useZ, options {event, icon, label}, distance)
Config.ThirdEyeName = 'qb-target' 			-- Name of third eye aplication

--LEO Configuration
Config.RequireMinimumLEO = true 			-- When on will require a minimum number of LEOs to be available to start robbery
Config.RequiredNumberLEO = 4 				-- Minimum number of LEO needed for robbery to start when Config.RequireMinimumLEO = true
Config.LEOJobName = {'police', 'bcso'} 		-- Job name of law enforcement officers
Config.Cooldown = 90						-- How long until the heist is able to be redone after activating (in minutes)
RegisterNetEvent('angelicxs-YachtHeist:PoliceAlert')
AddEventHandler('angelicxs-YachtHeist:PoliceAlert', function(coords)
    -- TriggerEvent("police:client:policeAlert", coords, "illegal Hunting in area")
    local data = exports['cd_dispatch']:GetPlayerInfo()
    TriggerServerEvent('cd_dispatch:AddNotification', {
        job_table = {'police', 'bcso'}, 
        coords = coords,
        title = '10-XXXX - Yacht Robbery',
        message = 'Reports of a '..data.sex..' robbing a yacht near '..data.street, 
        flash = 0,
        unique_id = tostring(math.random(0000000,9999999)),
        blip = {
            sprite = 410, 
            scale = 1.2, 
            colour = 5,
            flashes = false, 
            text = '911 - Yacht Robbery',
            time = (5*60*1000),
            sound = 1,
        }
    })
end)

-- Reward Config
Config.GoldBarChance = 25					-- Chance to receive gold bars instead of marked bills
Config.GoldBarName = 'goldbar'				-- Name of gold bar item
Config.GoldBarMin = 10						-- Minimum number of gold bars recevied
Config.GoldBarMax = 100						-- Maximum number of gold bars received
Config.MarkedBillName = 'markedbills'		-- Name of marked bill item
Config.MarkedBillMinNumberAmount = 1		-- Minimum number of marked bills received
Config.MarkedBillMaxNumberAmount = 5		-- Maximum number of marked bills received
Config.MarkedBillMin = 1000					-- Minimum value of marked bills
Config.MarkedBillMax = 10000				-- Maximum value of marked bills

--- BONUS LOOT FOR Config.UseThirdEye = true ONLY
Config.BonusLootSpots = {
	vector3(-2077.28, -1022.23, 5.88),
	vector3(-2078.78, -1016.27, 5.88),
	vector3(-2084.71, -1013.65, 5.88),
	vector3(-2089.3, -1009.75, 5.88),
	vector3(-2095.78, -1007.94, 5.88),
	vector3(-2097.74, -1015.94, 5.88),
	vector3(-2107.76, -1014.24, 5.89),
	vector3(-2094.26, -1015.02, 8.98),
	vector3(-2085.35, -1014.71, 8.97),
	vector3(-2087.57, -1021.51, 8.97),
	vector3(-2077.17, -1020.28, 8.97),
	vector3(-2057.0, -1023.27, 11.91),
	vector3(-2059.17, -1029.94, 11.91),
	vector3(-2075.21, -1025.65, 11.91),
	vector3(-2102.73, -1014.31, 5.88),


}
Config.BonusLootItems = {
	{name = "rolex", amount = 3},
	{name = "diamond_ring", amount = 4},
	{name = "goldchain", amount = 2},
	{name = "joint", amount = 5},
	{name = "cryptostick", amount = 1},
	{name = "weapon_combatpistol", amount = 1},
}
Config.RareLootSpot = vector3(-2085.87, -1018.23, 12.78)
Config.RareLootChance = 20
Config.RareLootItem = 'gold_monkey_idol'
Config.RareLootItemAmount = 1

-- Starting Ped Config
Config.StartPed = vector4(767.62, -1690.5, 37.55, 7.34)		-- Location for starting NPC
Config.StartModel = 'u_m_m_streetart_01'                   	-- Model of starting NPC
Config.StartBlip = false 				                	-- Enable Blip for starting NPC
Config.StartBlipIcon = 410 			                    	-- Starting blip icon (if Config.StarBlip = true)
Config.StartBlipColour = 50 			                	-- Colour of blip icon (if Config.StarBlip = true)
Config.StartBlipText = 'Yacht Informant'                	-- Blip text on map (if Config.StarBlip = true)

-- Guard Config
Config.GuardLocation = { 								-- Guard Location
	vector4(-2027.63, -1034.09, 5.88, 42.54),
	vector4(-2041.53, -1039.2, 5.88, 310.89),
	vector4(-2079.13, -1019.98, 5.88, 336.54),
	vector4(-2084.55, -1017.14, 5.88, 73.36),
	vector4(-2088.64, -1015.86, 5.88, 242.95),
	vector4(-2092.59, -1008.09, 5.88, 341.63),
	vector4(-2099.55, -1007.27, 5.88, 246.86),
	vector4(-2117.26, -1003.43, 7.9, 182.53),
	vector4(-2112.86, -1009.68, 9.46, 62.61),
	vector4(-2089.43, -1017.05, 8.97, 278.89),
	vector4(-2078.85, -1023.96, 8.97, 37.63),
	vector4(-2036.4, -1034.06, 8.97, 262.45),
	vector4(-2048.72, -1032.54, 11.91, 286.25),
	vector4(-2050.46, -1026.84, 11.91, 234.92),
	vector4(-2068.97, -1026.93, 11.91, 324.6),
	vector4(-2083.57, -1022.61, 12.78, 289.85),
	vector4(-2081.04, -1015.63, 12.78, 195.39),


}

Config.GuardType = { 									-- Guard models **Note the use of different gangs is intentional as they will start to fight each other as soon as the player interacts with them.
    "g_f_y_lost_01",
    "g_f_y_ballas_01",
	'g_m_m_korboss_01',
	'g_m_y_armgoon_02',
	'g_m_y_lost_03',
	'g_m_y_mexgoon_01',
}

Config.GuardWeapon = { 									-- Guard weapons
    'weapon_carbinerifle',
}
Config.GuardArmour = 200 								-- Guard Armour

Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'primary'
}

Config.Lang = {
	['AskJob'] = "Request Information On Yacht.",
	['request'] = 'Press ~r~[E]~w~ to request information on the yacht.',
	['startHeist'] = 'Some gangs are having a meet out on the yacht! Disable the engines, make some noise and loot it all!',
    ['working'] = 'Someone is working the yacht job right now.',
    ['mincops'] = 'No risk, no reward. Come back later!',
	['EngineDisable'] = "Attempt to disable engine!",
	['ReleaseTrolly'] = "Release Money Carts",
	['requestTrolley'] = 'Press ~r~[E]~w~ to release money carts.',
	['ReleaseedTrolly'] = 'Security systems are down!',
	['gained'] = "You got ",
	['goldBars'] = " gold bars!",
	['markedBills'] = " marked bills!",
	['lootTrolly3d'] = 'Press ~r~[E]~w~ to loot.',
	['lootTrolly'] = 'Loot Goods',
	['missRare'] = 'It appears empty!',
	['allDown'] = 'Security systems are already down!',

}