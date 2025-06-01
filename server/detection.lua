-- qb-anpr/server/detection.lua

-- Vehicle Detection System
RegisterNetEvent('qb-anpr:server:vehicleDetected', function(plate, cameraId, coords)
    local src = source
    plate = string.upper(plate)
    
    -- Check if vehicle is flagged
    if flaggedVehicles[plate] then
        local flagData = flaggedVehicles[plate]
        local officerName = GetPlayerName(flagData.flaggedBy)
        local location = GetStreetName(coords)
        
        -- Prepare alert data
        local alertData = {
            plate = plate,
            reason = flagData.reason,
            priority = flagData.priority,
            location = location,
            coords = coords,
            cameraId = cameraId,
            officerName = officerName,
            time = os.date('%H:%M:%S %d/%m/%Y'),
            notes = flagData.notes
        }
        
        -- Send alert to all police officers
        local players = QBCore.Functions.GetPlayers()
        for i = 1, #players do
            local Player = QBCore.Functions.GetPlayer(players[i])
            if Player and (Player.PlayerData.job.name == 'police' or Player.PlayerData.job.name == 'sheriff') then
                TriggerClientEvent('qb-anpr:client:anprAlert', players[i], alertData)
            end
        end
        
        -- Log detection to database
        MySQL.Async.execute(
            'INSERT INTO anpr_detections (plate, camera_id, coords, reason, priority, detection_time) VALUES (?, ?, ?, ?, ?, ?)',
            { plate, cameraId, json.encode(coords), flagData.reason, flagData.priority, os.date('%Y-%m-%d %H:%M:%S') }
        )
        
        -- Add to recent alerts
        table.insert(recentAlerts, 1, alertData)
        if #recentAlerts > 50 then
            table.remove(recentAlerts, 51)
        end
        
        print(('[ANPR] FLAGGED VEHICLE DETECTED: %s at camera %s - %s (Priority: %d)'):format(
            plate, cameraId, location, flagData.priority
        ))
    else
        -- Log all detections for record keeping (optional)
        MySQL.Async.execute(
            'INSERT INTO anpr_detections (plate, camera_id, coords, detection_time) VALUES (?, ?, ?, ?)',
            { plate, cameraId, json.encode(coords), os.date('%Y-%m-%d %H:%M:%S') }
        )
    end
end)

-- Get recent alerts
RegisterNetEvent('qb-anpr:server:getRecentAlerts', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or (Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'sheriff') then
        return
    end
    
    -- Get last 10 alerts
    local alerts = {}
    for i = 1, math.min(10, #recentAlerts) do
        table.insert(alerts, recentAlerts[i])
    end
    
    TriggerClientEvent('qb-anpr:client:showRecentAlerts', src, alerts)
end)

-- Log alert (called from client when alert is received)
RegisterNetEvent('qb-anpr:server:logAlert', function(alertData)
    -- This is called from client to ensure the alert is logged
    -- Already handled in vehicleDetected event
end)