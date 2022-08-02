local htmlEntities = module("lib/htmlEntities")
local Tools = module("lib/Tools")
local RageUIAdmin = module("cfg/admin_menu")
local Groups = module("cfg/groups")
-- this module define some admin menu functions

local player_lists = {}

local function ch_list(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"player.list") then
        if player_lists[player] then -- hide
            player_lists[player] = nil
            vRPclient.removeDiv(player,{"user_list"})
        else -- show
            local content = ""
            local count = 0
            for k,v in pairs(vRP.rusers) do
                count = count+1
                local source = vRP.getUserSource(k)
                vRP.getUserIdentity(k, function(identity)
                    if source ~= nil then
                        content = content.."<br />"..k.." => <span class=\"pseudo\">"..vRP.getPlayerName(source).."</span> <span class=\"endpoint\">"..'REDACATED'.."</span>"
                        if identity then
                            content = content.." <span class=\"name\">"..htmlEntities.encode(identity.firstname).." "..htmlEntities.encode(identity.name).."</span> <span class=\"reg\">"..identity.registration.."</span> <span class=\"phone\">"..identity.phone.."</span>"
                        end
                    end
                    
                    -- check end
                    count = count-1
                    if count == 0 then
                        player_lists[player] = true
                        local css = [[
                        .div_user_list{ 
                            margin: auto; 
                            padding: 8px; 
                            width: 650px; 
                            margin-top: 80px; 
                            background: black; 
                            color: white; 
                            font-weight: bold; 
                            font-size: 1.1em;
                        } 
                        
                        .div_user_list .pseudo{ 
                            color: rgb(0,255,125);
                        }
                        
                        .div_user_list .endpoint{ 
                            color: rgb(255,0,0);
                        }
                        
                        .div_user_list .name{ 
                            color: #309eff;
                        }
                        
                        .div_user_list .reg{ 
                            color: rgb(0,125,255);
                        }
                        
                        .div_user_list .phone{ 
                            color: rgb(211, 0, 255);
                        }
                        ]]
                        vRPclient.setDiv(player,{"user_list", css, content})
                    end
                end)
            end
        end
    end
end

local function ch_whitelist(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"player.whitelist") then
        vRP.prompt(player,"User id to whitelist: ","",function(player,id)
            id = parseInt(id)
            vRP.setWhitelisted(id,true)
            vRPclient.notify(player,{"whitelisted user "..id})
        end)
    end
end

local function ch_unwhitelist(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"player.unwhitelist") then
        vRP.prompt(player,"User id to un-whitelist: ","",function(player,id)
            id = parseInt(id)
            vRP.setWhitelisted(id,false)
            vRPclient.notify(player,{"un-whitelisted user "..id})
        end)
    end
end

local function ch_addgroup(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"player.group.add") then
        vRP.prompt(player,"User id: ","",function(player,id)
            if id then 
                id = parseInt(id)
                vRP.prompt(player,"Group to add: ","",function(player,group)
                    if Groups.groups[group] and Groups.groups[group]._config and Groups.groups[group]._config['special'] then 
                        if vRP.hasPermission(user_id, 'player.manage_' .. group) then
                                vRP.addUserGroup(id, group)
                                vRPclient.notify(player,{'~g~Success! Added Group: ' .. group})
                        else 
                            vRPclient.notify(player,{'~r~You do not have permission to add this group.'})
                        end
                    else 
                        vRP.addUserGroup(id, group)
                        vRPclient.notify(player,{'~g~Success! Added Group: ' .. group})
                    end 
                end)
            end 
        end)
    
    end
end

local function ch_removegroup(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"player.group.remove") then
        vRP.prompt(player,"User id: ","",function(player,id)
            id = parseInt(id)
            if id then 
                vRP.prompt(player,"Group to remove: ","",function(player,group)
                    if Groups.groups[group] and Groups.groups[group]._config and Groups.groups[group]._config['special'] then 
                        if vRP.hasPermission(user_id, 'player.manage_' .. group) then
                                vRP.removeUserGroup(id, group)
                                vRPclient.notify(player,{'~g~Success! Removed Group: ' .. group})
                        else 
                            vRPclient.notify(player,{'~r~You do not have permission to remove this group.'})
                        end
                    else 
                        vRP.removeUserGroup(id, group)
                        vRPclient.notify(player,{'~g~Success! Removed Group: ' .. group})
                    end 
                end)
            end
        end)
    end
end

local function ch_kick(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"player.kick") then
        vRP.prompt(player,"User id to kick: ","",function(player,id)
            id = parseInt(id)
            vRP.prompt(player,"Reason: ","",function(player,reason)
                local source = vRP.getUserSource(id)
                if source ~= nil then
                    saveKickLog(id, GetPlayerName(player), reason)
                    vRP.kick(source,reason)
                    vRPclient.notify(player,{"kicked user "..id})
                end
            end)
        end)
    end
end

RegisterNetEvent('vRP:RemoveWarning')
AddEventHandler('vRP:RemoveWarning', function(warningid)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id ~= nil and vRP.hasPermission(user_id,"admin.removewarning") then
        exports['ghmattimysql']:execute("DELETE FROM vrp_warnings WHERE warning_id = @uid", {uid = warningid})
        vRPclient.notify(source,{"~g~Removed Warning"})
    end
end)

local function ch_removewarning(player, choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"admin.removewarning") then
        vRP.prompt(player,"Warning ID to remove warning from: ","",function(player,idwarning)
            if idwarning and tonumber(idwarning) then 
                exports['ghmattimysql']:execute("DELETE FROM vrp_warnings WHERE warning_id = @uid", {uid = idwarning})
            else 
                vRPclient.notify(player,{"Please enter a warningID!"})
            end
        end)
    end
end

local function ch_ban(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"player.ban") then
        vRP.prompt(player,"User id to ban: ","",function(player,id)
            id = parseInt(id)
            if id then  -- Thanks to JamesUK <3 For updated temp bans
                vRP.prompt(player,"Reason: ","",function(player,reason)
                    if reason then 
                        vRP.prompt(player,"Duration of Ban (-1 for perm ban): ","",function(player,hours)
                            saveBanLog(id, GetPlayerName(player), reason, hours)
                            if tonumber(hours) then 
                                if tonumber(hours) == -1 then 
                                    vRP.ban(player,id,"perm",reason)
                                else 
                                    vRP.ban(player,id,hours,reason)
                                end
                            else 
                                vRPclient.notify(player,{"Please enter a number for the ban hours."})
                            end 
                        end)
                    else 
                        vRPclient.notify(player,{"Please enter a ban reason!"})
                    end 
                end)
            else 
                vRPclient.notify(player,{"Please enter an id to ban!"})
            end      
        end)
    end
end

local function ch_unban(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"player.unban") then
        vRP.prompt(player,"User id to unban: ","",function(player,id)
            id = parseInt(id)
            vRP.setBanned(id,false)
            vRPclient.notify(player,{"un-banned user "..id})
        end)
    end
end

local function ch_emote(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"player.custom_emote") then
        vRP.prompt(player,"Animation sequence ('dict anim optional_loops' per line): ","",function(player,content)
            local seq = {}
            for line in string.gmatch(content,"[^\n]+") do
                local args = {}
                for arg in string.gmatch(line,"[^%s]+") do
                    table.insert(args,arg)
                end
                
                table.insert(seq,{args[1] or "", args[2] or "", args[3] or 1})
            end
            
            vRPclient.playAnim(player,{true,seq,false})
        end)
    end
end

local function ch_sound(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"player.custom_sound") then
        vRP.prompt(player,"Sound 'dict name': ","",function(player,content)
            local args = {}
            for arg in string.gmatch(content,"[^%s]+") do
                table.insert(args,arg)
            end
            vRPclient.playSound(player,{args[1] or "", args[2] or ""})
        end)
    end
end

local function ch_coords(player,choice)
    vRPclient.getPosition(player,{},function(x,y,z)
        vRP.prompt(player,"Copy the coordinates using Ctrl-A Ctrl-C",x..","..y..","..z,function(player,choice) end)
    end)
end

RegisterNetEvent("getCoords")
AddEventHandler("getCoords", function()
    local player = source
    vRPclient.getPosition(player,{},function(x,y,z)
        vRP.prompt(player,"Copy the coordinates using Ctrl-A Ctrl-C",x..","..y..","..z,function(player,choice) end)
    end)
end)

local function ch_tptome(player,choice)
    vRPclient.getPosition(player,{},function(x,y,z)
        vRP.prompt(player,"User id:","",function(player,user_id) 
            local tplayer = vRP.getUserSource(tonumber(user_id))
            if tplayer ~= nil then
                vRPclient.teleport(tplayer,{x,y,z})
            end
        end)
    end)
end

local function ch_tpto(player,choice)
    vRP.prompt(player,"User id:","",function(player,user_id) 
        local tplayer = vRP.getUserSource(tonumber(user_id))
        if tplayer ~= nil then
            vRPclient.getPosition(tplayer,{},function(x,y,z)
                vRPclient.teleport(player,{x,y,z})
            end)
        end
    end)
end

local function ch_tptocoords(player,choice)
    vRP.prompt(player,"Coords x,y,z:","",function(player,fcoords) 
        local coords = {}
        for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
            table.insert(coords,tonumber(coord))
        end
        
        local x,y,z = 0,0,0
        if coords[1] ~= nil then x = coords[1] end
        if coords[2] ~= nil then y = coords[2] end
        if coords[3] ~= nil then z = coords[3] end
        
        vRPclient.teleport(player,{x,y,z})
    end)
end

local function ch_givemoney(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
        vRP.prompt(player,"Amount:","",function(player,amount) 
            amount = parseInt(amount)
            vRP.giveMoney(user_id, amount)
        end)
    end
end

local function ch_giveitem(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
        vRP.prompt(player,"Id name:","",function(player,idname) 
            idname = idname or ""
            vRP.prompt(player,"Amount:","",function(player,amount) 
                amount = parseInt(amount)
                vRP.giveInventoryItem(user_id, idname, amount,true)
            end)
        end)
    end
end


local AdminCooldown = {}

local function ch_calladmin(player,choice)
    local user_id = vRP.getUserId(player)
    if vRPConfig.AdminCoolDown then 
        if AdminCooldown[player] and not (os.time() > AdminCooldown[player]) then
            return vRPclient.notify(player,{"~r~Please wait 30 seconds before calling again."})
        else 
            AdminCooldown[player] = nil
        end
    end
    if user_id ~= nil then
        vRP.prompt(player,"Describe your problem:","",function(player,desc) 
            desc = desc or ""
            if desc ~= nil and desc ~= "" then
                local answered = false
                local players = {}
                AdminCooldown[player] = os.time() + tonumber(vRPConfig.AdminCooldownTime)
                for k,v in pairs(vRP.rusers) do
                    local player = vRP.getUserSource(tonumber(k))
                    -- check user
                    if vRP.hasPermission(k,"admin.tickets") and player ~= nil then
                        table.insert(players,player)
                    end
                end
                
                -- send notify and alert to all listening players
                for k,v in pairs(players) do
                    vRP.request(v,"Admin ticket (user_id = "..user_id..") take/TP to ?: "..htmlEntities.encode(desc), 60, function(v,ok)
                        if ok then -- take the call
                            if not answered then
                                -- answer the call
                                vRPclient.notify(player,{"An admin took your ticket."})
                                vRPclient.getPosition(player, {}, function(x,y,z)
                                    vRPclient.teleport(v,{x,y,z})
                                end)
                                answered = true
                            else
                                vRPclient.notify(v,{"Ticket already taken."})
                            end
                        end
                    end)
                end
            else
                vRPclient.notify(player,{"Empty Admin Call."})
            end
        end)
    end
end


--vRP Admin 


AddEventHandler("entityCreating",  function(entity)
    local owner = NetworkGetEntityOwner(entity)
    local model = GetEntityModel(entity)
    if (owner ~= nil and owner > 0) then
        local config = LoadResourceFile(GetCurrentResourceName(), "modules/banned-props.json")
        local configjson = json.decode(config)
        if configjson then 
            if configjson[tostring(model)] then
                CancelEvent()
            end
        end 
    end
end)

RegisterNetEvent('vRPAdmin:UpdateBlacklistedProps')
AddEventHandler('vRPAdmin:UpdateBlacklistedProps', function(entity)
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, 'player.addblacklistedprops') then 
        local config = LoadResourceFile(GetCurrentResourceName(), "modules/banned-props.json")
        local configjson = json.decode(config)
        configjson[entity] = true;
        SaveResourceFile(GetCurrentResourceName(), "modules/banned-props.json", json.encode(configjson, { indent = true }), -1)
    else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end
end)

RegisterNetEvent('vRPAdmin:ReturnPlayers')
AddEventHandler('vRPAdmin:ReturnPlayers', function()
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, 'vrp.adminmenu') then 
        local Table = {}
        local Buttons = {}
        local Config = {}
        for i,v in pairs(GetPlayers()) do 
            local user_id = vRP.getUserId(v)
            if user_id ~= nil then 
                Table[user_id] = {v, GetPlayerName(v)}
            end
        end
        for i,v in pairs(RageUIAdmin.Buttons) do 
            if vRP.hasPermission(user_id, v[2]) then 
                Buttons[i] = true
            end
        end
        for i,v in pairs(RageUIAdmin.MiscButtons) do 
            if vRP.hasPermission(user_id, v[2]) then 
                Config[i] = v[3]
            end
        end
        TriggerClientEvent('vRPAdmin:RecievePlayers', source, Table, Buttons, Config)
    end
    if vRP.hasPermission(user_id, "vrp.founder") then 
        TriggerClientEvent("returnDevOP", source, true)
    else
        TriggerClientEvent("returnDevOP", source, false)
    end
    if vRP.hasPermission(user_id, "player.cleanallcleanup") then 
        TriggerClientEvent("returnEnOP", source, true)
    else
        TriggerClientEvent("returnEnOP", source, false)
    end
end)

RegisterNetEvent('vRPAdmin:Groups')
AddEventHandler('vRPAdmin:Groups', function(id)
    local source = source
    local user_id = vRP.getUserId(source)
    local GroupsL = {}
    if vRP.hasPermission(user_id, 'vrp.adminmenu') then 
        for i,v in pairs(Groups.groups) do 
            if vRP.hasGroup(id, i) then
                GroupsL[i] = true;
            end
        end
        TriggerClientEvent('vRPAdmin:ReturnGroups', source, GroupsL)
    else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end
end)



RegisterNetEvent('hello')
AddEventHandler('hello', function(bool)
    userid = vRP.getUserId(source)
    if bool then
        vRP.addUserGroup(userid,'staffon')
    else
        vRP.removeUserGroup(userid,'staffon')
    end
end)

RegisterNetEvent('vRPAdmin:EntityCleanupGun')
AddEventHandler('vRPAdmin:EntityCleanupGun', function()
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, 'player.propcleanup') then
        TriggerClientEvent('vRPAdmin:EntityCleanupGun', source)
    else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
        vRPclient.notify(source,{"~r~You can not perform this action!"})
    end
end)

RegisterNetEvent('vRPAdmin:PropCleanup')
AddEventHandler('vRPAdmin:PropCleanup', function()
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, 'player.propcleanup') then
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"[Galaxy]", 'A Entity cleanup has been triggered!'}
          })
          Wait(0)
          for i,v in pairs(GetAllObjects()) do 
             DeleteEntity(v)
          end
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"[Galaxy]", "Entity Cleanup Completed! ^1( " .. GetPlayerName(source) .. " )"}
          })
        else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
        vRPclient.notify(source,{"~r~You can not perform this action!"})
    end
end)


RegisterNetEvent('vRPAdmin:DeAttachEntity')
AddEventHandler('vRPAdmin:DeAttachEntity', function()
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, 'player.propcleanup') then
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"[Galaxy]", 'A Deattach cleanup has been triggered!'}
          })
          TriggerClientEvent("vRPAdmin:EntityWipe", -1)
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"[Galaxy]", " Deattach Cleanup Completed ^1( " .. GetPlayerName(source) .. " )"}
          })
        else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
        vRPclient.notify(source,{"~r~You can not perform this action!"})
    end
end)

RegisterNetEvent('vRPAdmin:PedCleanup')
AddEventHandler('vRPAdmin:PedCleanup', function()
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, 'player.pedcleanup') then
          for i,v in pairs(GetAllPeds()) do 
             DeleteEntity(v)
          end
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"[Galaxy]", "Ped Cleanup Completed ^1( " .. GetPlayerName(source) .. " )"  }
          })
        else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
        vRPclient.notify(source,{"~r~You can not perform this action!"})
    end
end)


RegisterNetEvent('vRPAdmin:VehCleanup')
AddEventHandler('vRPAdmin:VehCleanup', function()
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, 'player.pedcleanup') then
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"[Galaxy]", "A Vehicle Cleanup has been Triggered, please wait 30 seconds!"}
          })
          Wait(30000)
          for i,v in pairs(GetAllVehicles()) do 
             DeleteEntity(v)
          end
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"[Galaxy]", "Vehicle Cleanup Completed! ^1(" .. GetPlayerName(source) .. " )"}
          })
        else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
        vRPclient.notify(source,{"~r~You can not perform this action!"})
    end
end)

RegisterNetEvent('vRPAdmin:CleanAll')
AddEventHandler('vRPAdmin:CleanAll', function()
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, 'player.cleanallcleanup') then
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"[Galaxy]", "A Vehicle, Ped, Enitity cleanup has been triggered!"}
          })
          Wait(0)
          for i,v in pairs(GetAllVehicles()) do 
            DeleteEntity(v)
         end
         for i,v in pairs(GetAllPeds()) do 
           DeleteEntity(v)
        end
        for i,v in pairs(GetAllObjects()) do
           DeleteEntity(v)
        end
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"[Galaxy]", "Vehicle, Ped, Entity Cleanup Completed ^1( " .. GetPlayerName(source) .. " )"}
          })
        else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
        vRPclient.notify(source,{"~r~You can not perform this action!"})
    end
end)


RegisterNetEvent('vRPAdmin:RemoveGroup')
AddEventHandler('vRPAdmin:RemoveGroup', function(id, group)
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, 'player.removeGroups') then
        if Groups.groups[group] and Groups.groups[group]._config and Groups.groups[group]._config['special'] then 
            if vRP.hasPermission(user_id, 'player.manage_' .. group) then
                    vRP.removeUserGroup(id, group)
                    vRPclient.notify(source,{'~g~Success! Removed Group: ' .. group})
                    local GroupsL = {}
                    for i,v in pairs(Groups.groups) do 
                        if vRP.hasGroup(id, i) then
                            GroupsL[i] = true;
                        end
                    end
                    TriggerClientEvent('vRPAdmin:ReturnGroups', source, GroupsL)
            else 
                vRPclient.notify(source,{'~r~You do not have permission to remove this group.'})
            end
        else 
            vRP.removeUserGroup(id, group)
            vRPclient.notify(source,{'~g~Success! Removed Group: ' .. group})
            local GroupsL = {}
            for i,v in pairs(Groups.groups) do 
                if vRP.hasGroup(id, i) then
                    GroupsL[i] = true;
                end
            end
            TriggerClientEvent('vRPAdmin:ReturnGroups', source, GroupsL)
        end 
    else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
        vRPclient.notify(source,{"~r~You can not perform this action!"})
    end 
end)


RegisterNetEvent('vRPAdmin:AddGroup')
AddEventHandler('vRPAdmin:AddGroup', function(id, group)
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id, 'player.addGroups') then
        if Groups.groups[group] and Groups.groups[group]._config and Groups.groups[group]._config['special'] then 
            if vRP.hasPermission(user_id, 'player.manage_' .. group) then
                    vRP.addUserGroup(id, group)
                    vRPclient.notify(source,{'~g~Success! Added Group: ' .. group})
                    local GroupsL = {}
                    for i,v in pairs(Groups.groups) do 
                        if vRP.hasGroup(id, i) then
                            GroupsL[i] = true;
                        end
                    end
                    TriggerClientEvent('vRPAdmin:ReturnGroups', source, GroupsL)
            else 
                vRPclient.notify(source,{'~r~You do not have permission to add this group.'})
            end
        else 
            vRP.addUserGroup(id, group)
            vRPclient.notify(source,{'~g~Success! Added Group: ' .. group})
            local GroupsL = {}
            for i,v in pairs(Groups.groups) do 
                if vRP.hasGroup(id, i) then
                    GroupsL[i] = true;
                end
            end
            TriggerClientEvent('vRPAdmin:ReturnGroups', source, GroupsL)
        end 
    else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

RegisterNetEvent('vRPAdmin:Revive')
AddEventHandler('vRPAdmin:Revive', function(id)
    local source = source 
    local SelectedPlrSource = vRP.getUserSource(id) 
    local userid = vRP.getUserId(source)
    if vRP.hasPermission(userid, 'player.revive') then
        if SelectedPlrSource then  
            vRPclient.varyHealth(SelectedPlrSource,{100})
            TriggerClientEvent("GRP:FixClient", SelectedPlrSource)
            vRPclient.notify(source,{"~g~Revived Player!"})
            vRPclient.notify(SelectedPlrSource, {"~g~An Admin (" .. userid .. ") Revived you!"})
        else 
            vRPclient.notify(source,{"~r~This player may have left the game."})
        end
    else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

RegisterNetEvent('vRPAdmin:Health')
AddEventHandler('vRPAdmin:Health', function(id)
    local source = source 
    local SelectedPlrSource = vRP.getUserSource(id) 
    local userid = vRP.getUserId(source)
    if vRP.hasPermission(userid, 'player.revive') then
        if SelectedPlrSource then  
            vRPclient.varyHealth(SelectedPlrSource,{100})
            vRPclient.notify(source,{"~g~Gave health to player!"})
            vRPclient.notify(SelectedPlrSource, {"~g~An Admin (" .. userid .. ") Gave halth to you!"})
        else 
            vRPclient.notify(source,{"~r~This player may have left the game."})
        end
    else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

RegisterNetEvent('vRPAdmin:GiveArmour')
AddEventHandler('vRPAdmin:GiveArmour', function(id)
    local source = source 
    local SelectedPlrSource = vRP.getUserSource(id) 
    local userid = vRP.getUserId(source)
    if vRP.hasPermission(userid, 'player.revive') then

        if SelectedPlrSource then  
            SetPedArmour(SelectedPlrSource, 95)
            vRPclient.notify(source,{"~g~Gave Armour to player!"})
            vRPclient.notify(SelectedPlrSource, {"~g~An Admin (" .. userid .. ") gave Armour to you!"})
        else 
            vRPclient.notify(source,{"~r~This player may have left the game."})
        end
    else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

RegisterNetEvent('vRPAdmin:SlapPlayer')
AddEventHandler('vRPAdmin:SlapPlayer', function(id)
    local source = source 
    local SelectedPlrSource = vRP.getUserSource(id) 
    local userid = vRP.getUserId(source)
    if vRP.hasPermission(userid, 'player.slap') then
        if SelectedPlrSource then  
            vRPclient.setHealth(SelectedPlrSource,{0})
            vRPclient.notify(source,{"~g~Slapped Player"})
        else 
            vRPclient.notify(source,{"~r~This player may have left the game."})
        end
    else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

local onesync = GetConvar('onesync', nil)
RegisterNetEvent('vRPAdmin:SpectatePlr')
AddEventHandler('vRPAdmin:SpectatePlr', function(id)
    local source = source 
    local SelectedPlrSource = vRP.getUserSource(id) 
    local userid = vRP.getUserId(source)
    if vRP.hasPermission(userid, 'player.spectate') then
        if SelectedPlrSource then  
            if onesync ~= "off" then 
                local ped = GetPlayerPed(SelectedPlrSource)
                local pedCoords = GetEntityCoords(ped)
                print(pedCoords)
                TriggerClientEvent('vRPAdmin:Spectate', source, SelectedPlrSource, pedCoords)
            else 
                TriggerClientEvent('vRPAdmin:Spectate', source, SelectedPlrSource)  
            end
        else 
            vRPclient.notify(source,{"~r~This player may have left the game."})
        end
    else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

RegisterNetEvent('vRPAdmin:TPTo')
AddEventHandler('vRPAdmin:TPTo', function(id)
    local source = source 
    local SelectedPlrSource = vRP.getUserSource(id) 
    local userid = vRP.getUserId(source)
    if vRP.hasPermission(userid, 'player.tpto') then
        if SelectedPlrSource then  
            if onesync ~= "off" then 
                local ped = GetPlayerPed(source)
                local otherPlr = GetPlayerPed(SelectedPlrSource)
                local pedCoords = GetEntityCoords(otherPlr)
                SetEntityCoords(ped, pedCoords)
            else 
                TriggerClientEvent('vRPAdmin:TPTo', source, false, id)  
            end
        else 
            vRPclient.notify(source,{"~r~This player may have left the game."})
        end
    else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

RegisterNetEvent('vRPAdmin:Bring')
AddEventHandler('vRPAdmin:Bring', function(id)
    local source = source 
    local SelectedPlrSource = vRP.getUserSource(id) 
    local userid = vRP.getUserId(source)
    if vRP.hasPermission(userid, 'player.tpto') then
        if SelectedPlrSource then  
            if onesync ~= "off" then 
                local ped = GetPlayerPed(source)
                local otherPlr = GetPlayerPed(SelectedPlrSource)
                local pedCoords = GetEntityCoords(ped)
                SetEntityCoords(otherPlr, pedCoords)
            else 
                TriggerClientEvent('vRPAdmin:Bring', SelectedPlrSource, false, id)  
            end
        else 
            vRPclient.notify(source,{"~r~This player may have left the game."})
        end
    else 
        print(GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

RegisterNetEvent('vRPAdmin:Kick')
AddEventHandler('vRPAdmin:Kick', function(id, reason, nof10)
    local source = source 
    local SelectedPlrSource = vRP.getUserSource(id) 
    local userid = vRP.getUserId(source)
    if vRP.hasPermission(userid, 'player.kick') then
        if SelectedPlrSource then  
            if not nof10 then 
                saveKickLog(id, GetPlayerName(source), reason)
            end
            vRP.kick(SelectedPlrSource,reason)
            vRPclient.notify(source,{'~g~Successfully kicked Player.'})
        end
    end
end)


RegisterNetEvent('vRPAdmin:AddCar')
AddEventHandler('vRPAdmin:AddCar', function(id, car)
    local source = source 
    local SelectedPlrSource = vRP.getUserSource(id) 
    local userid = vRP.getUserId(source)
    if vRP.hasPermission(userid, 'player.addcar') then
        if SelectedPlrSource and car ~= "" then  
            vRP.getUserIdentity(id, function(identity)	
                if not identity then
                    identity = {}
                    identity.registration = "JamesUK#6793"
                elseif not identity.registration then 
                    identity.registration = "JamesUK#6793"
                end	
                MySQL.execute("vRP/add_vehicle", {user_id = id, vehicle = car, registration = "P "..identity.registration})
            end)
            vRPclient.notify(source,{'~g~Successfully added Player\'s car'})
        else 
            vRPclient.notify(source,{'~r~Failed to add Player\'s car'})
        end
    end
end)

RegisterNetEvent('vRPAdmin:AddVIPCar')
AddEventHandler('vRPAdmin:AddCar', function(id, car)
    local source = source 
    local SelectedPlrSource = vRP.getUserSource(id) 
    local userid = vRP.getUserId(source)
    if vRP.hasPermission(userid, 'player.addcar') then
        if SelectedPlrSource and car ~= "" then  
            vRP.getUserIdentity(id, function(identity)	
                if not identity then
                    identity = {}
                    identity.registration = "JamesUK#6793"
                elseif not identity.registration then 
                    identity.registration = "JamesUK#6793"
                end	
                MySQL.execute("vRP/add_vehicle", {user_id = id, vehicle = vip, registration = "P "..identity.registration})
            end)
            vRPclient.notify(source,{'~g~Successfully added Player\'s car'})
        else 
            vRPclient.notify(source,{'~r~Failed to add Player\'s car'})
        end
    end
end)


RegisterNetEvent('vRPAdmin:ServerShutdown')
AddEventHandler('vRPAdmin:ServerShutdown', function()
    local source = source 
    local userid = vRP.getUserId(source)
    if vRP.hasPermission(userid, 'player.shutdownserver') then
        TriggerClientEvent('VRPAdmin:ActivateShutdown', -1)
        Wait(300000)
        for i,v in pairs(GetPlayers()) do 
            DropPlayer(v, 'This server has shutdown please try rejoining in a few minutes.')
        end
    end
end)


RegisterNetEvent('vRPAdmin:Ban')
AddEventHandler('vRPAdmin:Ban', function(id, hours, reason)
    local source = source 
    local SelectedPlrSource = vRP.getUserSource(id) 
    local userid = vRP.getUserId(source)
    local admin = GetPlayerName(source)
    if vRP.hasPermission(userid, 'player.ban') then
        if SelectedPlrSource then  
            if tonumber(hours) then 
                if tonumber(hours) == -1 then 
    
                    vRPclient.notify(source,{'~g~Successfully banned Player.'})

                    local banname = GetPlayerName(SelectedPlrSource)
                    local adminname = GetPlayerName(source)
                    local ban2Embed = {
                        {
                            ["color"] = "16777215",
                            ["title"] = ""..banname.." has been Banned",
                            ["description"] = "Name: **".. banname.."** [" .. id .. "] \nBanning Admin: **" .. adminname .. "** [" .. vRP.getUserId(source) .. "] \nReason: **"..reason.."**\nDuration: **"..hours.."**",
                            ["footer"] = {
                              ["text"] = "Galaxy RP - "..os.date("%X"),
                              ["icon_url"] = "https://i.imgur.com/ezFYVr9.png",
                            }
                        }
                    }
                    PerformHttpRequest("https://discord.com/api/webhooks/916729573943676928/D59OEhJp3ZkQij5wQU7tT06wPS7Ov484M4iKfbOEMQ9Q6zH21M1d89Ifk050uPYvnXe5", function(err, text, headers) end, "POST", json.encode({username = "Ban Logs", embeds = ban2Embed}), { ["Content-Type"] = "application/json" })
                    vRP.ban(source,id,"perm",reason)
                    saveBanLog(id, admin, reason, hours)
                else 
       
                    vRPclient.notify(source,{'~g~Successfully banned Player.'})

                    local banname = GetPlayerName(SelectedPlrSource)
                    local adminname = GetPlayerName(source)
                    local ban2Embed = {
                        {
                            ["color"] = "16777215",
                            ["title"] = ""..banname.." has been Banned",
                            ["description"] = "Name: **".. banname.."** [" .. id .. "] \nBanning Admin: **" .. adminname .. "** [" .. vRP.getUserId(source) .. "] \nReason: **"..reason.."**\nDuration: **"..hours.." Hours**",
                            ["footer"] = {
                              ["text"] = "Galaxy RP - "..os.date("%X"),
                              ["icon_url"] = "https://i.imgur.com/ezFYVr9.png",
                            }
                        }
                    }
                    PerformHttpRequest("https://discord.com/api/webhooks/916729573943676928/D59OEhJp3ZkQij5wQU7tT06wPS7Ov484M4iKfbOEMQ9Q6zH21M1d89Ifk050uPYvnXe5", function(err, text, headers) end, "POST", json.encode({username = "Ban Logs", embeds = ban2Embed}), { ["Content-Type"] = "application/json" })
                    vRP.ban(source,id,"perm",reason)
                    saveBanLog(id, admin, reason, hours)
                end
            else 
                vRPclient.notify(source,{"Please enter a number for the ban hours."})
            end 
        end
    end
end)




--vRP Admin



RegisterCommand('calladmin', function(source)
    local user_id = vRP.getUserId(source)
    if user_id ~= nil then
        if vRP.hasPermission(user_id,"player.calladmin") then
            ch_calladmin(source, nil)
        end
    end 
end)

local player_customs = {}

local function ch_display_custom(player, choice)
    vRPclient.getCustomization(player,{},function(custom)
        if player_customs[player] then -- hide
            player_customs[player] = nil
            vRPclient.removeDiv(player,{"customization"})
        else -- show
            local content = ""
            for k,v in pairs(custom) do
                content = content..k.." => "..json.encode(v).."<br />" 
            end
            
            player_customs[player] = true
            vRPclient.setDiv(player,{"customization",".div_customization{ margin: auto; padding: 8px; width: 500px; margin-top: 80px; background: black; color: white; font-weight: bold; ", content})
        end
    end)
end

local function ch_noclip(player, choice)
    vRPclient.toggleNoclip(player, {})
end

-- Hotkey Open Admin Menu 1/2
function vRP.openAdminMenu(source)
    vRP.buildMenu("admin", {player = source}, function(menudata)
        menudata.name = "Admin"
        menudata.css = {top="75px",header_color="rgba(0,125,255,0.75)"}
        vRP.openMenu(source,menudata)
    end)
end

-- Hotkey Open Admin Menu 2/2
function tvRP.openAdminMenu()
    vRP.openAdminMenu(source)
end

vRP.registerMenuBuilder("main", function(add, data)
    local user_id = vRP.getUserId(data.player)
    if user_id ~= nil then
        local choices = {}
        
        -- build admin menu
        choices["Admin"] = {function(player,choice)
            vRP.buildMenu("admin", {player = player}, function(menu)
                menu.name = "Admin"
                menu.css={top="75px",header_color="rgba(200,0,0,0.75)"}
                menu.onclose = function(player) vRP.openMainMenu(player) end -- nest menu

                if vRP.hasPermission(user_id,"player.unban") then
                    menu["Unban"] = {ch_unban}
                end

                if vRP.hasPermission(user_id,"player.coords") then
                    menu["Get Coords"] = {ch_coords}
                end

                if vRP.hasPermission(user_id,"player.tpto") then
                    menu["TpToCoords"] = {ch_tptocoords}
                end
                if vRP.hasPermission(user_id,"player.givemoney") then
                    menu["Give money"] = {ch_givemoney}
                end
                if vRP.hasPermission(user_id,"player.giveitem") then
                    menu["Give item"] = {ch_giveitem}
                end

                vRP.openMenu(player,menu)
            end)
        end}
        
        add(choices)
    end
end)

-- admin god mode
-- function task_god()
-- SetTimeout(10000, task_god)

-- for k,v in pairs(vRP.getUsersByPermission("admin.god")) do
-- vRP.setHunger(v, 0)
-- vRP.setThirst(v, 0)

-- local player = vRP.getUserSource(v)
-- if player ~= nil then
-- vRPclient.setHealth(player, {200})
-- end
-- end
-- end

-- task_god()



RegisterServerEvent("vRPAdmin:AdminTP")
AddEventHandler("vRPAdmin:AdminTP",function(id)
    local source = source 
    local SelectedPlrSource = vRP.getUserSource(id) 
    local userid = vRP.getUserId(source)
    if vRP.hasPermission(userid, 'player.tpto') then
        if SelectedPlrSource then 
        SetEntityCoords(SelectedPlrSource, 3501.3525390625,2590.6750488281,13.562794685364)
        vRPclient.notify(source,{"~w~Press ~g~G ~w~To Teleport with Player."})
            TriggerClientEvent("tpWith", source)
        vRPclient.notify(SelectedPlrSource, {"~g~You have been teleported to Admin Island"})
        vRPclient.notify(source, {"~g~You have teleported this player to Admin Island: "..SelectedPlrSource})
        end
    end
end)
