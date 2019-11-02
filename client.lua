local using = false
local lastPos = nil
local anim = "back"
local animscroll = 0
local oPlayer = false

local objects = {
	object = nil, ObjectVert = nil, ObjectVertY = nil, OjbectDir = nil, isBed = nil,
	locations = {
		[1] = {object="v_med_bed2", verticalOffset=-0.0, verticalOffsetY=0.0, direction=0.0, bed=true},
		[2] = {object="v_serv_ct_chair02", verticalOffset=-0.0, verticalOffsetY=0.0, direction=168.0, bed=false},
		[3] = {object="prop_off_chair_04", verticalOffset=-0.4, verticalOffsetY=0.0, direction=168.0, bed=false},
		[4] = {object="prop_off_chair_03", verticalOffset=-0.4, verticalOffsetY=0.0, direction=168.0, bed=false},
		[5] = {object="prop_off_chair_05", verticalOffset=-0.4, verticalOffsetY=0.0, direction=168.0, bed=false},
		[6] = {object="v_club_officechair", verticalOffset=-0.4, verticalOffsetY=0.0, direction=168.0, bed=false},
		[7] = {object="v_ilev_leath_chr", verticalOffset=-0.4, verticalOffsetY=0.0, direction=168.0, bed=false},
		[8] = {object="v_corp_offchair", verticalOffset=-0.4, verticalOffsetY=0.0, direction=168.0, bed=false},
		[9] = {object="v_med_emptybed", verticalOffset=-0.2, verticalOffsetY=0.13, direction=90.0, bed=false},
		[10] = {object="Prop_Off_Chair_01", verticalOffset=-0.5, verticalOffsetY=-0.1, direction=180.0, bed=false}
	}
}


CreateThread(function()
	while true do
		Wait(2000)
		oPlayer = PlayerPedId()
		local pedPos = GetEntityCoords(oPlayer)
		for k,v in pairs(objects.locations) do
			local objectC = GetClosestObjectOfType(pedPos.x, pedPos.y, pedPos.z, 0.8, GetHashKey(v.object), 0, 0, 0)
			local oEntityCoords = GetEntityCoords(objectC)
			local objectexits = DoesEntityExist(objectC)
			if objectexits then
				if GetDistanceBetweenCoords(oEntityCoords.x, oEntityCoords.y, oEntityCoords.z,pedPos) < 15.0 then
					if objectC ~= 0 then
						if objectC ~= objects.object then
							objects.object = objectC
							objects.ObjectVert = v.verticalOffset
							objects.ObjectVertY = v.verticalOffsetY
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
		if objects.object ~= nil and objects.ObjectVert ~= nil and objects.ObjectVertY ~= nil and objects.OjbectDir ~= nil and objects.isBed ~= nil then
			local player = oPlayer
			local getPlayerCoords = GetEntityCoords(player)
			local objectcoords = GetEntityCoords(objects.object)
			if GetDistanceBetweenCoords(objectcoords.x, objectcoords.y, objectcoords.z,getPlayerCoords) < 1.8 and not using then
				if objects.isBed == true then
					DrawText3Ds(objectcoords.x, objectcoords.y, objectcoords.z+0.30, "~g~E~w~ to lie on your "..anim)
					DrawText3Ds(objectcoords.x, objectcoords.y, objectcoords.z+0.20, "~w~ Switch between the stomach, back and sit with the ~g~arrow keys")
					if IsControlJustPressed(0, 175) then -- right
						animscroll = animscroll+1
						if animscroll == 0 then
							anim = "back"
						elseif animscroll == 1 then
							anim = "stomach"
						elseif animscroll == 2 then
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
							animscroll = 0
							anim = "back"
						end
					end
					if IsControlJustPressed(0, 38) then
						PlayAnimOnPlayer(objects.object, false, false, false, objects.isBed, player, objectcoords)
					end
				else
					DrawText3Ds(objectcoords.x, objectcoords.y, objectcoords.z+0.30, " ~g~G~w~ to sit")
					if IsControlJustPressed(0, 58) then
						PlayAnimOnPlayer(objects.object,objects.ObjectVert,objects.ObjectVertY,objects.OjbectDir, objects.isBed, player, objectcoords)
					end
				end
			end
			if using == true then
				Draw2DText("~g~F~w~ to stand up!",0,1,0.5,0.92,0.6,255,255,255,255)

				DisableControlAction( 0, 56, true )
				DisableControlAction( 0, 244, true )
				DisableControlAction( 0, 301, true )

				if IsControlJustPressed(0, 23) or IsControlJustPressed(0, 48) or IsControlJustPressed(0, 20) then
					ClearPedTasks(player)
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

function PlayAnimOnPlayer(object,vert,verty,dir, isBed, ped, objectcoords)
	lastPos = GetEntityCoords(ped)
	FreezeEntityPosition(object, true)
	SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z+-1.4)
	FreezeEntityPosition(ped, true)
	using = true
	if isBed == false then
		TaskStartScenarioAtPosition(ped, 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', objectcoords.x, objectcoords.y-verty, objectcoords.z-vert, GetEntityHeading(object)+dir, 0, true, true)
	else
		local verticalOffset = -1.4
		local direction = 0.0
		if anim == "back" then
			TaskStartScenarioAtPosition(ped, 'WORLD_HUMAN_SUNBATHE_BACK', objectcoords.x, objectcoords.y, objectcoords.z-verticalOffset, GetEntityHeading(object)+direction, 0, true, true)
		elseif anim == "stomach" then
			TaskStartScenarioAtPosition(ped, 'WORLD_HUMAN_SUNBATHE', objectcoords.x, objectcoords.y, objectcoords.z-verticalOffset, GetEntityHeading(object)+direction, 0, true, true)
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
