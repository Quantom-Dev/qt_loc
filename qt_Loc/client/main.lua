local ESX = exports["es_extended"]:getSharedObject()
local PlayerData = {}
local isMenuOpen = false
local currentRentalPoint = nil
local rentalBlips = {}
local rentalPeds = {}
local spawnedVehicle = nil
local rentalData = {}
local locationEnCours = false
local uiVisible = false
local pedVisible = false

Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    
    PlayerData = ESX.GetPlayerData()
    CreateRentalBlips()
    CreateRentalPeds()
    InitializeEvents()
    MainLoop()
end)

function CreateRentalBlips()
    for i, rentalPoint in ipairs(Config.RentalPoints) do
        local blip = AddBlipForCoord(rentalPoint.pos.x, rentalPoint.pos.y, rentalPoint.pos.z)
        SetBlipSprite(blip, rentalPoint.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, rentalPoint.blip.scale)
        SetBlipColour(blip, rentalPoint.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(rentalPoint.blip.label)
        EndTextCommandSetBlipName(blip)
        
        table.insert(rentalBlips, blip)
    end
end

function CreateRentalPeds()
    Citizen.CreateThread(function()
        for i, rentalPoint in ipairs(Config.RentalPoints) do
            local pedModel = GetHashKey(rentalPoint.ped.model)
            RequestModel(pedModel)
            
            while not HasModelLoaded(pedModel) do
                Citizen.Wait(50)
            end
            
            local ped = CreatePed(4, pedModel, rentalPoint.pos.x, rentalPoint.pos.y, rentalPoint.pos.z - 1.0, rentalPoint.ped.heading, false, true)
            
            SetEntityAsMissionEntity(ped, true, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ped, true)
            
            if rentalPoint.ped.scenario then
                TaskStartScenarioInPlace(ped, rentalPoint.ped.scenario, 0, true)
            end
            
            table.insert(rentalPeds, {
                entity = ped,
                rentalPointIndex = i
            })
            
            SetModelAsNoLongerNeeded(pedModel)
        end
    end)
end

function InitializeEvents()
    RegisterNetEvent('location_vehicules:openUI')
    AddEventHandler('location_vehicules:openUI', function(rentalPointIndex)
        if not isMenuOpen and not locationEnCours then
            currentRentalPoint = Config.RentalPoints[rentalPointIndex]
            OpenRentalUI()
        elseif locationEnCours then
            ESX.ShowNotification('Vous avez déjà un véhicule en location.')
        end
    end)
    
    RegisterNetEvent('location_vehicules:closeUI')
    AddEventHandler('location_vehicules:closeUI', function()
        CloseRentalUI()
    end)
    
    RegisterNetEvent('location_vehicules:rentVehicle')
    AddEventHandler('location_vehicules:rentVehicle', function(data)
        if not locationEnCours then
            RentVehicle(data)
        end
    end)
    
    RegisterNetEvent('location_vehicules:rentalConfirmed')
    AddEventHandler('location_vehicules:rentalConfirmed', function(data)
        if data.success then
            locationEnCours = true
            ESX.ShowNotification('Location confirmée. Le véhicule est à vous.')
        else
            locationEnCours = false
            if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
                DeleteVehicle(spawnedVehicle)
                spawnedVehicle = nil
            end
            ESX.ShowNotification('Location échouée. Vérifiez votre argent.')
            rentalData = {}
        end
    end)
    
    RegisterNetEvent('location_vehicules:returnVehicle')
    AddEventHandler('location_vehicules:returnVehicle', function()
        ReturnRentedVehicle()
    end)
end

function ShowHelpNotification(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, 5000)
end

function DrawMarker3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        
        DrawRect(_x, _y + 0.0125, 0.015 + text:len() / 370, 0.03, 0, 0, 0, 100)
    end
end

function MainLoop()
    Citizen.CreateThread(function()
        while true do
            local sleep = 500
            local playerCoords = GetEntityCoords(PlayerPedId())
            local isNearReturnPoint = false
            local isNearPed = false
            
            for i, rentalPoint in ipairs(Config.RentalPoints) do
                local returnDistance = #(playerCoords - rentalPoint.returnPos)
                
                if returnDistance < Config.DrawDistance and locationEnCours and IsInRentedVehicle() then
                    isNearReturnPoint = true
                    sleep = 0
                    DrawMarker(Config.MarkerType, rentalPoint.returnPos.x, rentalPoint.returnPos.y, rentalPoint.returnPos.z - 0.95, 
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                        Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 
                        255, 0, 0, 100, false, true, 2, false, nil, nil, false)
                    
                    if returnDistance < 2.0 then
                        if not uiVisible then
                            uiVisible = true
                            ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour retourner le véhicule loué")
                        end
                        
                        if IsControlJustReleased(0, 38) then
                            uiVisible = false
                            TriggerEvent('location_vehicules:returnVehicle')
                        end
                    elseif uiVisible then
                        uiVisible = false
                    end
                end
                
                local pedDistance = #(playerCoords - rentalPoint.pos)
                if pedDistance < Config.DrawDistance then
                    sleep = 0
                    
                    if pedDistance < 2.0 then
                        if not pedVisible and not locationEnCours then
                            pedVisible = true
                            ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour parler au loueur")
                        end
                        
                        if IsControlJustReleased(0, 38) then
                            if not locationEnCours then
                                TriggerEvent('location_vehicules:openUI', i)
                            else
                                ESX.ShowNotification('Vous avez déjà un véhicule en location.')
                            end
                        end
                    elseif pedDistance > 2.0 and pedVisible then
                        pedVisible = false
                    end
                end
            end
            
            if not isNearReturnPoint and uiVisible then
                uiVisible = false
            end
            
            Citizen.Wait(sleep)
        end
    end)
end

function OpenRentalUI()
    isMenuOpen = true
    
    local vehicles = {}
    for i, vehicle in ipairs(currentRentalPoint.vehicles) do
        table.insert(vehicles, {
            name = vehicle.name,
            model = vehicle.model,
            price = vehicle.price,
            category = vehicle.category,
            img = vehicle.img
        })
    end
    
    SendNUIMessage({
        type = "openRentalUI",
        vehicles = vehicles,
        colors = Config.Colors,
        paymentMethods = Config.PaymentMethods
    })
    
    SetNuiFocus(true, true)
end

function CloseRentalUI()
    isMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "closeRentalUI"
    })
end

function RentVehicle(data)
    CloseRentalUI()
    
    rentalData = {
        model = data.model,
        name = data.name,
        price = data.price,
        colorIndex = data.colorIndex,
        paymentMethod = data.paymentMethod
    }
    
    SpawnRentalVehicle(data.model, data.colorIndex)
    
    ESX.ShowNotification('Traitement de la location en cours...')
    
    Citizen.Wait(500)
    TriggerServerEvent('location_vehicules:payRental', rentalData)
end

function SpawnRentalVehicle(model, colorIndex)
    if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
        DeleteVehicle(spawnedVehicle)
        spawnedVehicle = nil
    end
    
    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    
    local timeout = 0
    while not HasModelLoaded(modelHash) do
        timeout = timeout + 1
        if timeout > 300 then
            ESX.ShowNotification('Impossible de charger le modèle du véhicule.')
            return
        end
        Citizen.Wait(50)
    end
    
    local spawnPos = currentRentalPoint.spawnPos
    
    spawnedVehicle = CreateVehicle(modelHash, spawnPos.x, spawnPos.y, spawnPos.z, spawnPos.w, true, false)
    
    if not DoesEntityExist(spawnedVehicle) then
        ESX.ShowNotification('Impossible de créer le véhicule.')
        return
    end
    
    SetVehicleColours(spawnedVehicle, colorIndex, colorIndex)
    SetVehicleDirtLevel(spawnedVehicle, 0)
    SetVehicleEngineOn(spawnedVehicle, true, true, false)
    SetVehicleDoorsLocked(spawnedVehicle, 1)
    
    SetVehicleNumberPlateText(spawnedVehicle, "BAD_LOC")
    
    TaskWarpPedIntoVehicle(PlayerPedId(), spawnedVehicle, -1)
    
    SetModelAsNoLongerNeeded(modelHash)
end

function ReturnRentedVehicle()
    if locationEnCours and IsInRentedVehicle() then
        if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
            DeleteVehicle(spawnedVehicle)
            spawnedVehicle = nil
        end
        
        ESX.ShowNotification('Vous avez retourné le véhicule.')
        
        rentalData = {}
        locationEnCours = false
    else
        ESX.ShowNotification('Vous devez être dans le véhicule loué pour le retourner.')
    end
end

function IsInRentedVehicle()
    return spawnedVehicle and DoesEntityExist(spawnedVehicle) and 
           GetVehiclePedIsIn(PlayerPedId(), false) == spawnedVehicle
end

RegisterNUICallback('closeMenu', function(data, cb)
    CloseRentalUI()
    cb('ok')
end)

RegisterNUICallback('rentVehicle', function(data, cb)
    TriggerEvent('location_vehicules:rentVehicle', data)
    cb('ok')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for i, blip in ipairs(rentalBlips) do
            RemoveBlip(blip)
        end
        
        for i, pedData in ipairs(rentalPeds) do
            if DoesEntityExist(pedData.entity) then
                DeleteEntity(pedData.entity)
            end
        end
        
        if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
            DeleteVehicle(spawnedVehicle)
        end
        
        if isMenuOpen then
            CloseRentalUI()
        end
    end
end)