-- qb-anpr/server/main.lua
local QBCore = exports['qb-core']:GetCoreObject()
local anprCameras = {}
local flaggedVehicles = {}
local recentAlerts = {}

-- Load data on resource start
CreateThread(function()
    Wait(1000) -- Wait for database to be ready
    
    local result = MySQL.Sync.fetchAll('SELECT * FROM anpr_cameras')
    if result then
        for i = 1, #result do
            anprCameras[result[i].id] = {
                id = result[i].id,
                x = result[i].x,
                y = result[i].y,
                z = result[i].z,
                heading = result[i].heading,
                deployedBy = result[i].deployed_by,
                deployedTime = result[i].deployed_time
            }
        end
    end
    
    local flaggedResult = MySQL.Sync.fetchAll('SELECT * FROM anpr_flagged_vehicles')
    if flaggedResult then
        for i = 1, #flaggedResult do
            flaggedVehicles[flaggedResult[i].plate] = {
                plate = flaggedResult[i].plate,
                reason = flaggedResult[i].reason,
                priority = flaggedResult[i].priority,
                flaggedBy = flaggedResult[i].flagged_by,
                dateAdded = flaggedResult[i].date_added,
                notes = flaggedResult[i].notes or ''
            }
        end
    end
    
    TriggerClientEvent('qb-anpr:client:updateCameras', -1, anprCameras)
    print('[ANPR] System loaded: ' .. #result .. ' cameras, ' .. #flaggedResult .. ' flagged vehicles')
end)

-- Helper function to get player name
function GetPlayerName(citizenid)
    local result = MySQL.Sync.fetchAll('SELECT charinfo FROM players WHERE citizenid = ?', { citizenid })
    if result and result[1] then
        local charinfo = json.decode(result[1].charinfo)
        return charinfo.firstname .. ' ' .. charinfo.lastname
    end
    return 'Unknown Officer'
end

-- Helper function to get street name
function GetStreetName(coords)
    -- You can implement a custom street name system here
    -- For now, return coordinates
    return 'Grid Ref: ' .. math.floor(coords.x) .. ', ' .. math.floor(coords.y)
end

-- Camera Management Events
RegisterNetEvent('qb-anpr:server:deployCamera', function(coords, heading)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or (Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'sheriff') then
        return
    end
    
    -- Check if player has ANPR camera item
    local hasItem = Player.Functions.GetItemByName('anpr_camera')
    if not hasItem then
        TriggerClientEvent('QBCore:Notify', src, 'You need an ANPR camera unit to deploy', 'error')
        return
    end
    
    -- Remove item
    Player.Functions.RemoveItem('anpr_camera', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['anpr_camera'], 'remove')
    
    -- Deploy camera
    local cameraId = MySQL.Sync.insert('INSERT INTO anpr_cameras (x, y, z, heading, deployed_by, deployed_time) VALUES (?, ?, ?, ?, ?, ?)', {
        coords.x, coords.y, coords.z, heading, Player.PlayerData.citizenid, os.date('%Y-%m-%d %H:%M:%S')
    })
    
    anprCameras[cameraId] = {
        id = cameraId,
        x = coords.x,
        y = coords.y,
        z = coords.z,
        heading = heading,
        deployedBy = Player.PlayerData.citizenid,
        deployedTime = os.date('%Y-%m-%d %H:%M:%S')
    }
    
    TriggerClientEvent('qb-anpr:client:updateCameras', -1, anprCameras)
    TriggerClientEvent('QBCore:Notify', src, '📹 ANPR Camera deployed successfully', 'success')
    
    -- Log deployment
    print(('[ANPR] Camera deployed by %s [%s] at %s, %s, %s'):format(
        GetPlayerName(Player.PlayerData.citizenid),
        Player.PlayerData.citizenid,
        coords.x, coords.y, coords.z
    ))
end)

RegisterNetEvent('qb-anpr:server:removeCamera', function(cameraId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or (Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'sheriff') then
        return
    end
    
    if anprCameras[cameraId] then
        -- Give back item
        Player.Functions.AddItem('anpr_camera', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['anpr_camera'], 'add')
        
        -- Remove from database
        MySQL.Async.execute('DELETE FROM anpr_cameras WHERE id = ?', { cameraId })
        anprCameras[cameraId] = nil
        
        TriggerClientEvent('qb-anpr:client:updateCameras', -1, anprCameras)
        TriggerClientEvent('QBCore:Notify', src, '📦 ANPR Camera packed up successfully', 'success')
        
        print(('[ANPR] Camera %s removed by %s [%s]'):format(
            cameraId,
            GetPlayerName(Player.PlayerData.citizenid),
            Player.PlayerData.citizenid
        ))
    end
end)

-- Get camera list
RegisterNetEvent('qb-anpr:server:getCameraList', function()
    local src = source
    local cameraList = {}
    
    for k, camera in pairs(anprCameras) do
        table.insert(cameraList, camera)
    end
    
    TriggerClientEvent('qb-anpr:client:showCameraList', src, cameraList)
end)