local ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('location_vehicules:checkMoney', function(source, cb, price, account)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        cb(false)
        return
    end
    
    price = tonumber(price) or 0
    
    if account == 'money' then
        cb(xPlayer.getMoney() >= price)
    elseif account == 'bank' then
        cb(xPlayer.getAccount('bank').money >= price)
    else
        cb(false)
    end
end)

RegisterServerEvent('location_vehicules:payRental')
AddEventHandler('location_vehicules:payRental', function(data)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        TriggerClientEvent('location_vehicules:rentalConfirmed', source, {success = false})
        return
    end
    
    local price = 0
    if type(data.price) == 'number' then
        price = data.price
    elseif type(data.price) == 'string' then
        price = tonumber(data.price) or 0
    end
    
    local paymentMethod = "money"
    if type(data.paymentMethod) == 'string' then
        paymentMethod = data.paymentMethod
    elseif type(data.paymentMethod) == 'table' and data.paymentMethod.value then
        paymentMethod = data.paymentMethod.value
    end
    
    local success = false
    
    if paymentMethod == 'money' then
        if xPlayer.getMoney() >= price then
            xPlayer.removeMoney(price)
            success = true
            TriggerClientEvent('esx:showNotification', source, 'Vous avez payé ' .. ESX.Math.GroupDigits(price) .. '$ pour la location.')
        else
            TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez pas assez d\'argent liquide.')
        end
    elseif paymentMethod == 'bank' then
        if xPlayer.getAccount('bank').money >= price then
            xPlayer.removeAccountMoney('bank', price)
            success = true
            TriggerClientEvent('esx:showNotification', source, 'Vous avez payé ' .. ESX.Math.GroupDigits(price) .. '$ depuis votre compte bancaire.')
        else
            TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez pas assez d\'argent sur votre compte bancaire.')
        end
    else
        TriggerClientEvent('esx:showNotification', source, 'Mode de paiement invalide.')
    end
    
    TriggerClientEvent('location_vehicules:rentalConfirmed', source, {success = success})
end)

RegisterServerEvent('location_vehicules:processRefund')
AddEventHandler('location_vehicules:processRefund', function(amount, paymentMethod)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    amount = tonumber(amount) or 0
    
    local paymentType = "money"
    if type(paymentMethod) == "table" and paymentMethod.value then
        paymentType = paymentMethod.value
    elseif type(paymentMethod) == "string" then
        paymentType = paymentMethod
    end
    
    if paymentType == 'money' then
        xPlayer.addMoney(amount)
    elseif paymentType == 'bank' then
        xPlayer.addAccountMoney('bank', amount)
    end
    
    TriggerClientEvent('esx:showNotification', source, 'Vous avez été remboursé de ' .. ESX.Math.GroupDigits(amount) .. '$.')
end)