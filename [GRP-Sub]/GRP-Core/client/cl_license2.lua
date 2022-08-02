RMenu.Add('LicenseCentre', 'main', RageUI.CreateMenu("", "License Center", 1300, 50, "licenses", "licenses"))
RMenu.Add("LicenseCentre", "confirm", RageUI.CreateSubMenu(RMenu:Get('LicenseCentre', 'main',  1300, 50)))


RageUI.CreateWhile(1.0, RMenu:Get('LicenseCentre', 'main'), nil, function()


    RageUI.IsVisible(RMenu:Get('LicenseCentre', 'main'), true, false, true, function()

        for i , p in pairs(license.licenses.jobs) do 
            RageUI.Button(p.name , nil, { RightLabel = license.currency .. tostring(p.priceshow) }, true, function(Hovered, Active, Selected)
                if Selected then

                    cPrice = p.price
                    cGroup = p.group
                    cName = p.name
                    cPriceshop = p.priceshow
                    
                end
            end, RMenu:Get("LicenseCentre", "confirm"))
        end

    end, function()

    end)
end)

RageUI.CreateWhile(1.0, RMenu:Get("LicenseCentre", "confirm"), nil, function()
    RageUI.IsVisible(RMenu:Get("LicenseCentre", "confirm"), true, false, true, function()  
        RMenu:Get("LicenseCentre", "confirm"):SetSubtitle("Are you sure?")
        RageUI.Button("Confirm" , nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
            if Selected then
                TriggerServerEvent('LicenseCentre:BuyGroup', cPrice, cGroup, cName, cPriceshop)
            end
        end, RMenu:Get("LicenseCentre", "main"))
        RageUI.Button("Decline" , nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
            if Selected then
                
            end
        end, RMenu:Get("LicenseCentre", "main"))
       

    end)
end)

inLicenseMenu = false
Citizen.CreateThread(function() 
    while true do
            local v1 = license.coords

            if isInArea(v1, 100.0) then 
                DrawMarker(2, v1+1 - 0.98, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 0, 222, 61, 155, true, true, 0, 0, 0, 0, 0)
            end

            if inLicenseMenu == false then

                if isInArea(v1, 1.4) then 
                    alert('Press ~INPUT_VEH_HORN~ to access License Centre')
                    if IsControlJustPressed(0, 51) then 
                        currentAmmunition = k
                        RageUI.Visible(RMenu:Get("LicenseCentre", "main"), true)
                        inLicenseMenu = true
                    end
                end

            end
            if isInArea(v1, 1.4) == false and inLicenseMenu and k == currentAmmunition then

                RageUI.CloseAll()
                inLicenseMenu = false

            end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("GRP:PlaySound")
AddEventHandler("GRP:PlaySound", function(status)
    if status == 1 then 
        PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", 0)
    end

    if status == 2 then 
        PlaySoundFrontend(-1, "Hack_Failed", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", 0)
    end
end)




function isInArea(v, dis) 
    
    if #(GetEntityCoords(PlayerPedId(-1)) - v) <= dis then  
        return true
    else 
        return false
    end
end

function alert(msg) 
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0,0,1,-1)
end




