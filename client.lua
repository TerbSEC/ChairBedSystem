-- // OPTIMIZE PAIR!
local ObjectAr = {}
local currObject = 0

-- // BASIC
local InUse = false
local IsTextInUse = false
local PlyLastPos = 0

-- // ANIMATION
local Anim = 'sit'
local AnimScroll = 0

-- // WHEN YOU ARE OUT OF RANGE, IT DOSENT TICK EVERY MS!
local canSleep = false

CreateThread(function()
    while true do
        Wait(1000)
        if (InUse == false) and (canSleep == true) then
            plyCoords = GetEntityCoords(PlayerPedId(), 0)
            for k, v in pairs(Config.objects.locations) do
                local oObject = GetClosestObjectOfType(plyCoords.x, plyCoords.y, plyCoords.z, 1.0, GetHashKey(v.object), 0, 0, 0)
                if (oObject ~= 0) then
                    local oObjectCoords = GetEntityCoords(oObject)
                    local ObjectDistance = #(vector3(oObjectCoords) - plyCoords)
                    if (ObjectDistance < 2) then
                        if (oObject ~= currObject) then
                            currObject = oObject
                            local oObjectExists = DoesEntityExist(oObject)
                            ObjectAr = {
                                fObject = oObject,
                                fObjectCoords = oObjectCoords,
                                fObjectcX = v.verticalOffsetX,
                                fObjectcY = v.verticalOffsetY,
                                fObjectcZ = v.verticalOffsetZ,
                                fObjectDir = v.direction,
                                fObjectIsBed = v.bed
                            }
                        end
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        canSleep = true
        if ObjectAr.fObject ~= nil then
            ply = PlayerPedId()
            plyCoords = GetEntityCoords(ply, 0)
            ObjectCoords = ObjectAr.ObjectCoords
            local ObjectDistance = #(vector3(ObjectAr.fObjectCoords) - plyCoords)
            if (ObjectDistance < 1.8 and not InUse) then
                if (ObjectAr.fObjectIsBed) == true then
                    
                    --[[ ARROW RIGHT ]]
                    if IsControlJustPressed(0, 175) then -- right
                        if (AnimScroll ~= 2) then
                            AnimScroll = AnimScroll + 1
                        end
                        if AnimScroll == 1 then
                            Anim = "back"
                        elseif AnimScroll == 2 then
                            Anim = "stomach"
                        end
                    end
                    
                    --[[ ARROW LEFT ]]
                    if IsControlJustPressed(0, 174) then -- left
                        if (AnimScroll ~= 0) then
                            AnimScroll = AnimScroll - 1
                        end
                        if AnimScroll == 1 then
                            Anim = "back"
                        elseif AnimScroll == 0 then
                            Anim = "sit"
                        end
                    end
                    
                    if (Anim == 'sit') then
                        
                        -- // Sorry for this shitty space solution :joy: <br> dont work with the buttons ;(
                        DisplayHelpText(Config.Text.SitOnBed .. '                               ' .. Config.Text.SwitchBetween, 1)
                    else
                        -- // Sorry for this shitty space solution :joy: <br> dont work with the buttons ;(
                        DisplayHelpText(Config.Text.LieOnBed .. ' ' .. Anim .. '                          ' .. Config.Text.SwitchBetween, 1)
                    end
                    if IsControlJustPressed(0, Config.objects.ButtonToLayOnBed) then
                        TriggerServerEvent('ChairBedSystem:Server:Enter', ObjectAr, ObjectAr.fObjectCoords)
                    end
                else
                    DisplayHelpText(Config.Text.SitOnChair, 1)
                    if IsControlJustPressed(0, Config.objects.ButtonToSitOnChair) then
                        TriggerServerEvent('ChairBedSystem:Server:Enter', ObjectAr, ObjectAr.fObjectCoords)
                    end
                end
            end
            
            if (inUse) then
                DisplayHelpText(Config.Text.Standup, 0)
                if IsControlJustPressed(0, Config.objects.ButtonToStandUp) then
                    inUse = false
                    TriggerServerEvent('ChairBedSystem:Server:Leave', ObjectAr.fObjectCoords)
                    ClearPedTasksImmediately(ply)
                    FreezeEntityPosition(ply, false)
                    
                    local x, y, z = table.unpack(PlyLastPos)
                    if GetDistanceBetweenCoords(x, y, z, plyCoords) < 10 then
                        SetEntityCoords(ply, PlyLastPos)
                    end
                end
            end
        end
        if canSleep then
            Citizen.Wait(1000)
        end
    end
end)

CreateThread(function()
	while Config.Healing ~= 0 do
		Wait(Config.Healing*1000)
		if inUse == true then
			if ObjectAr.fObjectIsBed == true then
				local health = GetEntityHealth(oPlayer)
				if health <= 199 then
					SetEntityHealth(oPlayer,health+1)
				end
			end
		end
	end
end)

RegisterNetEvent('ChairBedSystem:Client:Animation')
AddEventHandler('ChairBedSystem:Client:Animation', function(v, objectcoords)
    local object = v.fObject
    local vertx = v.fObjectcX
    local verty = v.fObjectcY
    local vertz = v.fObjectcZ
    local dir = v.fObjectDir
    local isBed = v.fObjectIsBed
    local objectcoords = v.fObjectCoords
    
    local ped = PlayerPedId()
    PlyLastPos = GetEntityCoords(ped)
    FreezeEntityPosition(object, true)
    FreezeEntityPosition(ped, true)
    inUse = true
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

function DisplayHelpText(text, sound)
    canSleep = false
    AddTextEntry('label', text)
    BeginTextCommandDisplayHelp('label')
    DisplayHelpTextFromStringLabel(0, 0, sound, -1)
    EndTextCommandDisplayText(0.5, 0.5)
end


function Animation(dict, anim, ped)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    
    TaskPlayAnim(ped, dict, anim, 8.0, 1.0, -1, 1, 0, 0, 0, 0)
end
