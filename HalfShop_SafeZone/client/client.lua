ESX = nil

Citizen.CreateThread(function() while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Citizen.Wait(100) end end)

Zones = {
    {
        {243.98, -822.66, 30.04}, -- Parking Place des Cubes
        {198.83, -805.81, 31.11},
		{228.31, -723.21, 34.91},
		{274.8, -739.83, 39.01},
		{271.96, -748.71, 34.64},
		{258.41, -786.76, 30.43},
		{252.58, -785.0, 30.5},
		{247.72, -798.33, 30.31},
		{251.52, -800.2, 30.33},
		{244.05, -822.75, 30.04}
    },
	{
        {409.98, -965.85, 29.47}, -- Police
        {409.03, -1033.94, 29.36},
		{489.82, -1025.79, 28.16},
		{488.9, -966.43, 27.36}
    },
	{
        {}, -- Autre..
        {},
		{},
		{}
    }
}

local hasRun = false

local function insidePolygon( point)
    local oddNodes = false
    for i = 1, #Zones do
        local Zone = Zones[i]
        local j = #Zone
        for i = 1, #Zone do
            if (Zone[i][2] < point.y and Zone[j][2] >= point.y or Zone[j][2] < point.y and Zone[i][2] >= point.y) then
                if (Zone[i][1] + ( point[2] - Zone[i][2] ) / (Zone[j][2] - Zone[i][2]) * (Zone[j][1] - Zone[i][1]) < point.x) then
                    oddNodes = not oddNodes;
                end
            end
            j = i;
        end
    end
    return oddNodes 
end

Citizen.CreateThread(function()
    while true do
        local iPed = GetPlayerPed(-1)
        Citizen.Wait(0)
        point = GetEntityCoords(iPed,true)
        local inZone = insidePolygon(point)
        if Config.AfficherSZ then
            drawPoly(inZone)
        end
        if inZone then
		    DisableControlAction(1, 45, true) 
		    DisableControlAction(2, 37, true)
			DisableControlAction(0, 106, true) 
            NetworkSetFriendlyFireOption(false)
            DisablePlayerFiring(player,true)      
            if IsPedInAnyVehicle(iPed, false) then
                veh = GetVehiclePedIsUsing(iPed)
                SetEntityCanBeDamaged(veh, false)
            end
			if IsDisabledControlJustPressed(1, 45) then
			    SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true) 
                ESX.ShowNotification("~h~~r~[SafeZone] ~g~- Vous ne pouvez pas vous Fight en Zone Safe !")
            end
			if IsDisabledControlJustPressed(2, 37) then
                SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true) 
                ESX.ShowNotification("~h~~r~[SafeZone] ~g~- Vous ne pouvez pas sortir d'armes dans une Zone Safe !")
            end
			if IsDisabledControlJustPressed(0, 106) then 
                SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
                ESX.ShowNotification("~h~~r~[SafeZone] ~g~- Vous ne pouvez pas ouvrir le feu dans une Zone Safe !")
            end
            SetEntityInvincible(iPed, true)
			SetPedCanRagdoll(iPed, false)
			ClearPedBloodDamage(iPed)
			ResetPedVisibleDamage(iPed)
            ClearPedLastWeaponDamage(iPed)
            for _, players in ipairs(GetActivePlayers()) do
                if IsPedInAnyVehicle(GetPlayerPed(players), true) then
                    veh = GetVehiclePedIsUsing(GetPlayerPed(players))
                    SetEntityNoCollisionEntity(iPed, veh, true)
                end
            end
            hasRun = false
        else
            if not hasRun then
                hasRun = true
                SetEntityInvincible(iPed, false)
                SetPedCanRagdoll(iPed, true)
                NetworkSetFriendlyFireOption(true)
                if IsPedInAnyVehicle(iPed, false) then
                    veh = GetVehiclePedIsUsing(iPed)
                    SetEntityCanBeDamaged(veh, true)
                end
                if IsPedInAnyVehicle(GetPlayerPed(players), true) then
                    veh = GetVehiclePedIsUsing(GetPlayerPed(players))
                    SetEntityNoCollisionEntity(iPed, veh, false)
                end
            end
        end
    end 
end)

function DisplayHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringKeyboardDisplay(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end


function drawPoly(isEntityZone)
    local iPed = GetPlayerPed(-1)
    for i = 1, #Zones do
        local Zone = Zones[i]
        local j = #Zone
        for i = 1, #Zone do
                
            local zone = Zone[i]
            if i < #Zone then
                local p2 = Zone[i+1]
                _drawWall(zone, p2)
            end
        end
    
        if #Zone > 2 then
            local firstPoint = Zone[1]
            local lastPoint = Zone[#Zone]
            _drawWall(firstPoint, lastPoint)
        end
    end
end


  function _drawWall(p1, p2)
    local bottomLeft = vector3(p1[1], p1[2], p1[3] - 1.5)
    local topLeft = vector3(p1[1], p1[2],  p1[3] + Config.Hauteur)
    local bottomRight = vector3(p2[1], p2[2], p2[3] - 1.5)
    local topRight = vector3(p2[1], p2[2], p2[3] + Config.Hauteur)
    
    DrawPoly(bottomLeft,topLeft,bottomRight,0,255,0,48)
    DrawPoly(topLeft,topRight,bottomRight,0,255,0,48)
    DrawPoly(bottomRight,topRight,topLeft,0,255,0,48)
    DrawPoly(bottomRight,topLeft,bottomLeft,0,255,0,48)
  end