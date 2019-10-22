local trunkSecondaryInventory = {
    type = 'trunk',
    owner = 'XYZ123'
}

local openVehicle
local globalplate = nil
local vehiclePlate = nil
local PlayerData = {}
local lastChecked = 0

function all_trim(s)
  if s then
    return s:match "^%s*(.*)":match "(.-)%s*$"
  else
    return "noTagProvided"
  end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, Config.TrunkOpenControl) then
            local vehicle = ESX.Game.GetVehicleInDirection()
            if DoesEntityExist(vehicle) then
                myVeh = false
                PlayerData = ESX.GetPlayerData()
                if lastChecked < GetGameTimer() - 60000 then
                    lastChecked = GetGameTimer()
                    while vehiclePlate == nil do
                        TriggerServerEvent("disc_trunk_inventory:getOwnedVehicule")
                        Citizen.Wait(0)
                    end
                else
                    for k,v in pairs (vehiclePlate) do
                        local vPlate = all_trim(v.plate)
                        local vFront = all_trim(GetVehicleNumberPlateText(vehicle))
                        if vPlate == vFront then
                            myVeh = true
                        end
                    end
                end
                if not Config.CheckOwnership or (Config.AllowPolice and (PlayerData.job.name == "police")) or (Config.CheckOwnership and myVeh) then
                    local locked = GetVehicleDoorLockStatus(vehicle) == 2
                    if not locked then
                        local class = GetVehicleClass(vehicle)
                        if vehicle ~= nil then
                            trunkSecondaryInventory.owner = GetVehicleNumberPlateText(vehicle)
                            trunkSecondaryInventory.type = 'trunk-' .. class
                            openVehicle = vehicle
                            SetVehicleDoorOpen(openVehicle, 5, false)
                            openInventory(trunkSecondaryInventory)
                            local playerPed = GetPlayerPed(-1)
                            if not IsEntityPlayingAnim(playerPed, 'mini@repair', 'fixing_a_player', 3) then
                                ESX.Streaming.RequestAnimDict('mini@repair', function()
                                    TaskPlayAnim(playerPed, 'mini@repair', 'fixing_a_player', 8.0, -8, -1, 49, 0, 0, 0, 0)
                                end)
                            end
                        end
                    end
                else
                    ESX.ShowNotification('This is ~r~not~w~ your vehicle')
                end
            end
        end
    end
end
)

RegisterNUICallback('NUIFocusOff', function()
    if openVehicle ~= nil then
        SetVehicleDoorShut(openVehicle, 5, false)
        openVehicle = nil
        ClearPedSecondaryTask(GetPlayerPed(-1))
    end
end)

RegisterNetEvent("disc_trunk_inventory:setOwnedVehicule")
AddEventHandler(  "disc_trunk_inventory:setOwnedVehicule",function(vehicle)
    vehiclePlate = vehicle
end)
