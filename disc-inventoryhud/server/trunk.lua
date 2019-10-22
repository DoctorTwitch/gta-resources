Citizen.CreateThread(function()
    --Player
    for k,v in ipairs(Config.VehicleSlot) do
        TriggerEvent('disc-inventoryhud:RegisterInventory', {
            name = 'trunk-' .. k,
            label = 'Trunk',
            slots = v,
            getInventory = function(identifier, cb)
                getInventory(identifier, 'trunk-' .. k, cb)
            end,
            saveInventory = function(identifier, inventory)
                if table.length(inventory) > 0 then
                    saveInventory(identifier, 'trunk-' .. k, inventory)
                else
                    deleteInventory(identifier, 'trunk-' .. k)
                end
            end,
            getDisplayInventory = function(identifier, cb, source)
                getDisplayInventory(identifier, 'trunk-' .. k, cb, source)
            end
        })
    end
end)

RegisterServerEvent("disc_trunk_inventory:getOwnedVehicule")
AddEventHandler("disc_trunk_inventory:getOwnedVehicule",function()
    local vehicules = {}
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @owner",{
        ["@owner"] = xPlayer.identifier
    },
    function(result)
        if result ~= nil and #result > 0 then
            for _, v in pairs(result) do
                local vehicle = json.decode(v.vehicle)
                table.insert(vehicules, {plate = vehicle.plate})
            end
        end
        TriggerClientEvent("disc_trunk_inventory:setOwnedVehicule", _source, vehicules)
    end)
end)