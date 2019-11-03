local using = false
local lastPos = nil
local anim = "back"
local animscroll = 0
local oPlayer = false
Config = {}

CreateThread(function()
	while true do
		Wait(1000)
		oPlayer = PlayerPedId()
		local pedPos = GetEntityCoords(oPlayer)
		for k,v in pairs(Config.objects.locations) do
			local oSelectedObject = GetClosestObjectOfType(pedPos.x, pedPos.y, pedPos.z, 0.8, GetHashKey(v.object), 0, 0, 0)
			local oEntityCoords = GetEntityCoords(oSelectedObject)
			local objectexits = DoesEntityExist(oSelectedObject)
			if objectexits then
				if GetDistanceBetweenCoords(oEntityCoords.x, oEntityCoords.y, oEntityCoords.z,pedPos) < 15.0 then
					if oSelectedObject ~= 0 then
						local objects = Config.objects
						if oSelectedObject ~= objects.object then
							objects.object = oSelectedObject
							objects.ObjectVertX = v.verticalOffsetX
							objects.ObjectVertY = v.verticalOffsetY
							objects.ObjectVertZ = v.verticalOffsetZ
							objects.OjbectDir = v.direction
							objects.isBed = v.bed
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
		local objects = Config.objects
		if objects.object ~= nil and objects.ObjectVertX ~= nil and objects.ObjectVertY ~= nil and objects.ObjectVertZ ~= nil and objects.OjbectDir ~= nil and objects.isBed ~= nil then
			local player = oPlayer
			local getPlayerCoords = GetEntityCoords(player)
			local objectcoords = GetEntityCoords(objects.object)
			if GetDistanceBetweenCoords(objectcoords.x, objectcoords.y, objectcoords.z,getPlayerCoords) < 1.8 and not using then
				if objects.isBed == true then
					if anim == "sit" then
						DrawText3Ds(objectcoords.x, objectcoords.y, objectcoords.z+0.30, Config.Text.SitOnBed)
					else
						DrawText3Ds(objectcoords.x, objectcoords.y, objectcoords.z+0.30, Config.Text.LieOnBed.." "..anim)
					end
					DrawText3Ds(objectcoords.x, objectcoords.y, objectcoords.z+0.20, Config.Text.SwitchBetween)
					if IsControlJustPressed(0, 175) then -- right
						animscroll = animscroll+1
						if animscroll == 0 then
							anim = "back"
						elseif animscroll == 1 then
							anim = "stomach"
						elseif animscroll == 2 then
							anim = "sit"
						elseif animscroll == 3 then
							animscroll = 1
						end
					end

					if IsControlJustPressed(0, 174) then -- left
						animscroll = animscroll-1
						if animscroll == -1 then
							animscroll = 0
						elseif animscroll == 0 then
							anim = "back"
						elseif animscroll == 1 then
							anim = "stomach"
						elseif animscroll == 2 then
							anim = "sit"
						elseif animscroll == 3 then
							animscroll = 0
							anim = "back"
						end
					end
					if IsControlJustPressed(0, 38) then
						PlayAnimOnPlayer(objects.object,objects.ObjectVertX,objects.ObjectVertY,objects.ObjectVertZ,objects.OjbectDir, objects.isBed, player, objectcoords)
					end
				else
					DrawText3Ds(objectcoords.x, objectcoords.y, objectcoords.z+0.30, Config.Text.SitOnChair)
					if IsControlJustPressed(0, 58) then
						PlayAnimOnPlayer(objects.object,objects.ObjectVertX,objects.ObjectVertY,objects.ObjectVertZ,objects.OjbectDir, objects.isBed, player, objectcoords)
					end
				end
			end
			if using == true then
				Draw2DText("~g~F~w~ to stand up!",0,1,0.5,0.92,0.6,255,255,255,255)

				if IsControlJustPressed(0, 23) or IsControlJustPressed(0, 48) or IsControlJustPressed(0, 20) then
					ClearPedTasksImmediately(player)
					using = false
					local x,y,z = table.unpack(lastPos)
					if GetDistanceBetweenCoords(x, y, z,getPlayerCoords) < 10 then
						SetEntityCoords(player, lastPos)
					end
					FreezeEntityPosition(player, false)
				end
			end
		end
	end
end)

if Config.Healing ~= 0 then
	CreateThread(function()
		while true do
			local objects = Config.objects
			Wait(Config.Healing*1000)
			if using == true then
				if objects.isBed == true then
					local health = GetEntityHealth(oPlayer)
					if health <= 199 then
						SetEntityHealth(oPlayer,health+1)
					end
				end
			end
		end
	end)
end


function PlayAnimOnPlayer(object,vertx,verty,vertz,dir, isBed, ped, objectcoords)
	lastPos = GetEntityCoords(ped)
	FreezeEntityPosition(object, true)
	FreezeEntityPosition(ped, true)
	using = true
	if isBed == false then
		TaskStartScenarioAtPosition(ped, Config.objects.SitAnimation, objectcoords.x+vertx, objectcoords.y-verty, objectcoords.z-vertz, GetEntityHeading(object)+dir, 0, true, true)
	else
		if anim == "back" then

			SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z+0.5)
			SetEntityHeading(ped,  GetEntityHeading(object)-180.0)
			local dict = Config.objects.BedBackAnimation.dict
			local anim = Config.objects.BedBackAnimation.anim

			RequestAnimDict(dict)
			while not HasAnimDictLoaded(dict) do
				Citizen.Wait(0)
			end

			TaskPlayAnim(ped, dict , anim, 8.0, 1.0, -1, 1, 0, 0, 0, 0 )
		elseif anim == "stomach" then
			TaskStartScenarioAtPosition(ped, Config.objects.BedStomachAnimation, objectcoords.x+vertx, objectcoords.y+verty, objectcoords.z-vertz, GetEntityHeading(object)+dir, 0, true, true)
		elseif anim == "sit" then
			TaskStartScenarioAtPosition(ped, Config.objects.BedSitAnimation, objectcoords.x+vertx, objectcoords.y+verty, objectcoords.z-vertz, GetEntityHeading(object)+180.0, 0, true, true)
		end
	end
end




function DrawText3Ds(x,y,z, text)
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

function Draw2DText(text,font,centre,x,y,scale,r,g,b,a)
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
