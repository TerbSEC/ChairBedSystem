--
-- * Created with PhpStorm
-- * User: Terbium
-- * Date: 12/07/2021
-- * Time: 13:09
--

local PlayerPed = false
local PlayerPos = false
local PlayerLastPos = 0

local InUse = false

-- // ANIMATION
local Anim = 'sit'
local AnimScroll = 0

Citizen.CreateThread(function()
    while true do
        PlayerPed = PlayerPedId()
        PlayerPos = GetEntityCoords(PlayerPedId())
        Citizen.Wait(500)
    end
end)


Citizen.CreateThread(function()
    while true do
        local inRange = false
        for i = 1, #Config.objects.locations do
            local current = Config.objects.locations[i]
            local coordsObject = GetEntityCoords(current.object)
            local dist = #(PlayerPos - vector3(coordsObject.x, coordsObject.y, coordsObject.z))
            if dist <= 3.0 then
                inRange = true
                if dist <= 2.0 and not InUse then

                    if (current.bed == true) then
                        if IsControlJustPressed(0, 175) then RightScroller() end
                        if IsControlJustPressed(0, 174) then LeftScroller() end
                        if (Anim == 'sit') then
                            DrawText3Ds(coordsObject.x, coordsObject.y, coordsObject.z, Config.Text.SitOnBed .. ' | ' .. Config.Text.SwitchBetween)
                        else
                            DrawText3Ds(coordsObject.x, coordsObject.y, coordsObject.z, Config.Text.LieOnBed .. ' ~g~' .. Anim .. '~w~ | ' .. Config.Text.SwitchBetween)
                        end
                        if IsControlJustPressed(0, Config.objects.ButtonToLayOnBed) then
                            TriggerServerEvent('ChairBedSystem:Server:Enter', current, coordsObject)
                        end
                    else
                        DrawText3Ds(coordsObject.x, coordsObject.y, coordsObject.z, Config.Text.SitOnChair)
                        if IsControlJustPressed(0, Config.objects.ButtonToSitOnChair) then
                            TriggerServerEvent('ChairBedSystem:Server:Enter', current, coordsObject)
                        end 
                    end
                end

                if (InUse) then
                    DrawText3Ds(coordsObject.x, coordsObject.y, coordsObject.z, Config.Text.Standup)
                    if IsControlJustPressed(0, Config.objects.ButtonToStandUp) then
                        InUse = false
                        TriggerServerEvent('ChairBedSystem:Server:Leave', coordsObject)
                        ClearPedTasksImmediately(PlayerPed)
                        FreezeEntityPosition(PlayerPed, false)
                        
                        local x, y, z = table.unpack(PlayerLastPos)
                        local dist = #(PlayerPos - vector3(x, y, z))
                        if dist <= 10 then
                            SetEntityCoords(PlayerPed, PlayerLastPos)
                        end
                    end
                end
            end
        end

        if not inRange then
            Citizen.Wait(2000)
        end
        Citizen.Wait(3)
    end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2000)
		for i = 1, #Config.objects.locations do
			local current = Config.objects.locations[i]
            object = GetClosestObjectOfType(PlayerPos, 1.0, GetHashKey(current.objName), false, false, false)
            if object ~= 0 then
                current.object = object
			end
		end
	end
end)


function RightScroller()
    if (AnimScroll ~= 2) then
        AnimScroll = AnimScroll + 1
    end
    if AnimScroll == 1 then
        Anim = "back"
    elseif AnimScroll == 2 then
        Anim = "stomach"
    end
end

function LeftScroller()
    if (AnimScroll ~= 0) then
        AnimScroll = AnimScroll - 1
    end
    if AnimScroll == 1 then
        Anim = "back"
    elseif AnimScroll == 0 then
        Anim = "sit"
    end
end

RegisterNetEvent('ChairBedSystem:Client:Animation')
AddEventHandler('ChairBedSystem:Client:Animation', function(v, coords)
    local object = v.object
    local vertx = v.verticalOffsetX
    local verty = v.verticalOffsetY
    local vertz = v.verticalOffsetZ
    local dir = v.direction
    local isBed = v.bed
    local objectcoords = coords
    
    local ped = PlayerPed
    PlayerLastPos = GetEntityCoords(ped)
    FreezeEntityPosition(object, true)
    FreezeEntityPosition(ped, true)
    InUse = true
    if isBed == false then
        if Config.objects.SitAnimation.dict ~= nil then
            SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z + 0.5)
            SetEntityHeading(ped, GetEntityHeading(object) - 180.0)
            local dict = Config.objects.SitAnimation.dict
            local anim = Config.objects.SitAnimation.anim
            
            AnimLoadDict(dict, anim, ped)
        else
            TaskStartScenarioAtPosition(ped, Config.objects.SitAnimation.anim, objectcoords.x + vertx, objectcoords.y + verty, objectcoords.z - vertz, GetEntityHeading(object) + dir, 0, true, true)
        end
    else
        if Anim == 'back' then
            if Config.objects.BedBackAnimation.dict ~= nil then
                SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z + 0.5)
                SetEntityHeading(ped, GetEntityHeading(object) - 180.0)
                local dict = Config.objects.BedBackAnimation.dict
                local anim = Config.objects.BedBackAnimation.anim
                
                Animation(dict, anim, ped)
            else
                TaskStartScenarioAtPosition(ped, Config.objects.BedBackAnimation.anim, objectcoords.x + vertx, objectcoords.y + verty, objectcoords.z - vertz, GetEntityHeading(object) + dir, 0, true, true
            )
            end
        elseif Anim == 'stomach' then
            if Config.objects.BedStomachAnimation.dict ~= nil then
                SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z + 0.5)
                SetEntityHeading(ped, GetEntityHeading(object) - 180.0)
                local dict = Config.objects.BedStomachAnimation.dict
                local anim = Config.objects.BedStomachAnimation.anim
                
                Animation(dict, anim, ped)
            else
                TaskStartScenarioAtPosition(ped, Config.objects.BedStomachAnimation.anim, objectcoords.x + vertx, objectcoords.y + verty, objectcoords.z - vertz, GetEntityHeading(object) + dir, 0, true, true)
            end
        elseif Anim == 'sit' then
            if Config.objects.BedSitAnimation.dict ~= nil then
                SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z + 0.5)
                SetEntityHeading(ped, GetEntityHeading(object) - 180.0)
                local dict = Config.objects.BedSitAnimation.dict
                local anim = Config.objects.BedSitAnimation.anim
                
                Animation(dict, anim, ped)
            else
                TaskStartScenarioAtPosition(ped, Config.objects.BedSitAnimation.anim, objectcoords.x + vertx, objectcoords.y + verty, objectcoords.z - vertz, GetEntityHeading(object) + 180.0, 0, true, true)
            end
        end
    end
end)
