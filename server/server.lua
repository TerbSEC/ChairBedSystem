--
-- * Created with PhpStorm
-- * User: Terbium
-- * Date: 12/07/2021
-- * Time: 13:09
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
AddEventHandler('ChairBedSystem:Server:Enter', function(object, objectcoords)
    local oSource = source
    if oArray[objectcoords] == nil then
        oPlayerUse[oSource] = objectcoords
        oArray[objectcoords] = true
        TriggerClientEvent('ChairBedSystem:Client:Animation', oSource, object, objectcoords)
    end
end)


RegisterServerEvent('ChairBedSystem:Server:Leave')
AddEventHandler('ChairBedSystem:Server:Leave', function(objectcoords)
    local oSource = source

    oPlayerUse[oSource] = nil
    oArray[objectcoords] = nil
end)

