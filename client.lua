local oUsing = false
local oLastPos = nil
local oAnim = "back"
local oAnimscroll = 0
local oPlayer = false
local oPlayerCoords = false
local oCanSleep = true
local oCooldown = 0
Config = {}

CreateThread(function()
	while true do
		Wait(1000)
		oPlayer = PlayerPedId()
		oPlayerCoords = GetEntityCoords(oPlayer)
		if oCooldown > 0 then
			oCooldown = oCooldown-1
		end
		if oUsing == false and oCanSleep == true then
			for k,v in pairs(Config.objects.locations) do
				local oSelectedObject = GetClosestObjectOfType(oPlayerCoords.x, oPlayerCoords.y, oPlayerCoords.z, 0.8, GetHashKey(v.object), 0, 0, 0)
				local oEntityCoords = GetEntityCoords(oSelectedObject)
				local objectexits = DoesEntityExist(oSelectedObject)
				if objectexits then
					if GetDistanceBetweenCoords(oEntityCoords.x, oEntityCoords.y, oEntityCoords.z,oPlayerCoords) < 10.0 then
						if oSelectedObject ~= 0 then
							local objects = Config.objects
							if oSelectedObject ~= objects.Object then
								objects.Object = oSelectedObject
								objects.ObjectVertX = v.verticalOffsetX
								objects.ObjectVertY = v.verticalOffsetY
								objects.ObjectVertZ = v.verticalOffsetZ
								objects.ObjectDir = v.direction
								objects.isBed = v.bed
							end
						end
					end
				end
			end
		end
	end
end)


CreateThread(function()
	while true do
		Wait(1)
		oCanSleep = true
		local objects = Config.objects
		if objects.Object ~= nil and objects.ObjectVertX ~= nil and objects.ObjectVertY ~= nil and objects.ObjectVertZ ~= nil and objects.ObjectDir ~= nil and objects.isBed ~= nil then
			local player = oPlayer
			local getPlayerCoords = oPlayerCoords
			local objectcoords = GetEntityCoords(objects.Object)
			if GetDistanceBetweenCoords(objectcoords.x, objectcoords.y, objectcoords.z,getPlayerCoords) < 1.8 and not oUsing then
				if objects.isBed == true then
					if oAnim == "sit" then
						DrawText3D(objectcoords.x, objectcoords.y, objectcoords.z+0.30, Config.Text.SitOnBed)
					else
						DrawText3D(objectcoords.x, objectcoords.y, objectcoords.z+0.30, Config.Text.LieOnBed.." "..oAnim)
					end
					DrawText3D(objectcoords.x, objectcoords.y, objectcoords.z+0.20, Config.Text.SwitchBetween)
					if IsControlJustPressed(0, 175) then -- right
						oAnimscroll = oAnimscroll+1
						if oAnimscroll == 0 then
							oAnim = "back"
						elseif oAnimscroll == 1 then
							oAnim = "stomach"
						elseif oAnimscroll == 2 then
							oAnim = "sit"
						elseif oAnimscroll == 3 then
							oAnimscroll = 1
						end
					end

					if IsControlJustPressed(0, 174) then -- left
						oAnimscroll = oAnimscroll-1
						if oAnimscroll == -1 then
							oAnimscroll = 0
						elseif oAnimscroll == 0 then
							oAnim = "back"
						elseif oAnimscroll == 1 then
							oAnim = "stomach"
						elseif oAnimscroll == 2 then
							oAnim = "sit"
						elseif oAnimscroll == 3 then
							oAnimscroll = 0
							oAnim = "back"
						end
					end
					if IsControlJustPressed(0, objects.ButtonToLayOnBed) then
						if Config.Cooldown ~= 0 and oCooldown == 0 then
							oCooldown = Config.Cooldown
							TriggerServerEvent('ChairBedSystem:Server:Enter', objects, objectcoords)
						end
					end
				else
					DrawText3D(objectcoords.x, objectcoords.y, objectcoords.z+0.30, Config.Text.SitOnChair)
					if IsControlJustPressed(0, objects.ButtonToSitOnChair) then
						if Config.Cooldown ~= 0 and oCooldown == 0 then
							oCooldown = Config.Cooldown
							TriggerServerEvent('ChairBedSystem:Server:Enter', objects, objectcoords)
						end
					end
				end
			end
			if oUsing == true then
				DrawText2D(Config.Text.Standup,0,1,0.5,0.92,0.6,255,255,255,255)

				if IsControlJustPressed(0, objects.ButtonToStandUp) then
					TriggerServerEvent('ChairBedSystem:Server:Leave', GetEntityCoords(objects.Object))
					ClearPedTasksImmediately(player)
					oUsing = false
					local x,y,z = table.unpack(oLastPos)
					if GetDistanceBetweenCoords(x, y, z,getPlayerCoords) < 10 then
						SetEntityCoords(player, oLastPos)
					end
					FreezeEntityPosition(player, false)
				end
			end
		end

		if oCanSleep then
			Citizen.Wait(1000)
		end
	end
end)

CreateThread(function()
	while Config.Healing ~= 0 do
		local objects = Config.objects
		Wait(Config.Healing*1000)
		if oUsing == true then
			if objects.isBed == true then
				local health = GetEntityHealth(oPlayer)
				if health <= 199 then
					SetEntityHealth(oPlayer,health+1)
				end
			end
		end
	end
end)


RegisterNetEvent("ChairBedSystem:Client:Animation")
AddEventHandler("ChairBedSystem:Client:Animation", function(objects,objectcoords)
	local object = objects.Object
	local vertx = objects.ObjectVertX
	local verty = objects.ObjectVertY
	local vertz = objects.ObjectVertZ
	local dir = objects.ObjectDir
	local isBed = objects.isBed

	local ped = oPlayer
	oLastPos = oPlayerCoords
	FreezeEntityPosition(object, true)
	FreezeEntityPosition(ped, true)
	oUsing = true
	if isBed == false then
		if Config.objects.SitAnimation.dict ~= nil then
			SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z+0.5)
			SetEntityHeading(ped,  GetEntityHeading(object)-180.0)
			local dict = Config.objects.SitAnimation.dict
			local anim = Config.objects.SitAnimation.anim

			AnimLoadDict(dict, anim, ped)
		else
			TaskStartScenarioAtPosition(ped, Config.objects.SitAnimation.anim, objectcoords.x+vertx, objectcoords.y+verty, objectcoords.z-vertz, GetEntityHeading(object)+dir, 0, true, true)
		end
	else
		if oAnim == "back" then
			if Config.objects.BedBackAnimation.dict ~= nil then
				SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z+0.5)
				SetEntityHeading(ped,  GetEntityHeading(object)-180.0)
				local dict = Config.objects.BedBackAnimation.dict
				local anim = Config.objects.BedBackAnimation.anim

				Animation(dict, anim, ped)
			else
				TaskStartScenarioAtPosition(ped, Config.objects.BedBackAnimation.anim, objectcoords.x+vertx, objectcoords.y+verty, objectcoords.z-vertz, GetEntityHeading(object)+dir, 0, true, true)
			end
		elseif oAnim == "stomach" then
			if Config.objects.BedStomachAnimation.dict ~= nil then
				SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z+0.5)
				SetEntityHeading(ped,  GetEntityHeading(object)-180.0)
				local dict = Config.objects.BedStomachAnimation.dict
				local anim = Config.objects.BedStomachAnimation.anim

				Animation(dict, anim, ped)
			else
				TaskStartScenarioAtPosition(ped, Config.objects.BedStomachAnimation.anim, objectcoords.x+vertx, objectcoords.y+verty, objectcoords.z-vertz, GetEntityHeading(object)+dir, 0, true, true)
			end
		elseif oAnim == "sit" then
			if Config.objects.BedSitAnimation.dict ~= nil then
				SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z+0.5)
				SetEntityHeading(ped,  GetEntityHeading(object)-180.0)
				local dict = Config.objects.BedSitAnimation.dict
				local anim = Config.objects.BedSitAnimation.anim

				Animation(dict, anim, ped)
			else
				TaskStartScenarioAtPosition(ped, Config.objects.BedSitAnimation.anim, objectcoords.x+vertx, objectcoords.y+verty, objectcoords.z-vertz, GetEntityHeading(object)+180.0, 0, true, true)
			end

		end
	end
end)

function Animation(dict, anim, ped)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(0)
	end


	TaskPlayAnim(ped, dict , anim, 8.0, 1.0, -1, 1, 0, 0, 0, 0 )
end




function DrawText3D(x,y,z, text)
	oCanSleep = false
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)

	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
		local factor = (string.len(text)) / 350
		DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
	end
end

function DrawText2D(text,font,centre,x,y,scale,r,g,b,a)
	oCanSleep = false

	SetTextFont(6)
	SetTextProportional(6)
	SetTextScale(scale/1.0, scale/1.0)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end
