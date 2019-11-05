--
-- * Created with PhpStorm
-- * User: Terbium
-- * Date: 05/11/2019
-- * Time: 02:21
--

local oArray = {}
local oPlayerUse = {}


AddEventHandler('playerDropped', function()
    local oSource = source
    if oPlayerUse[oSource] ~= nil then
        oArray[oPlayerUse[oSource]] = nil
        oPlayerUse[oSource] = nil
    end
end)


RegisterServerEvent('ChairBedSystem:Server:Enter')
AddEventHandler('ChairBedSystem:Server:Enter', function(object,vertx,verty,vertz,dir, isBed, objectcoords)
    local oSource = source
    if oArray[objectcoords] == nil then
        oPlayerUse[oSource] = objectcoords
        oArray[objectcoords] = true
        TriggerClientEvent('ChairBedSystem:Client:Animation', oSource, object,vertx,verty,vertz,dir, isBed, objectcoords)
    end
end)


RegisterServerEvent('ChairBedSystem:Server:Leave')
AddEventHandler('ChairBedSystem:Server:Leave', function(id)
    local oSource = source

    oPlayerUse[oSource] = nil
    oArray[id] = nil
end)

