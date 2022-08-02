local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "LicenseCentre")

RegisterServerEvent("LicenseCentre:BuyGroup")
AddEventHandler('LicenseCentre:BuyGroup', function(price, job, name, priceshow)
    local source = source
    userid = vRP.getUserId({source})
    local coords = vec3(1701.4835205078,3783.9167480469,34.766910552979)
    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)

    if #(playerCoords - coords) <= 5.0 then
        if vRP.hasGroup({userid, job}) then 
            vRPclient.notify(source, {"~o~You have already purchased this license!"})
            TriggerClientEvent("GRP:PlaySound", source, 2)
        else
            if vRP.tryFullPayment({userid, price}) then

                vRP.addUserGroup({userid,job})

                vRPclient.notify(source, {"~g~Purchased " .. job .. " License for "..license.currency..tostring(priceshow) .. " ❤️"})
                TriggerClientEvent("GRP:PlaySound", source, 1)

                else 
                vRPclient.notify(source, {"~r~You do not have enough money to purchase this license!"})
                    TriggerClientEvent("GRP:PlaySound", source, 2)
            end
        end
    else 
        vRP.banConsole({userid,"perm","Cheating/ Triggering Events"})
    end
end)





