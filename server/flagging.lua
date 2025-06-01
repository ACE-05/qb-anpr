-- qb-anpr/server/flagging.lua

-- Vehicle Flagging Events
RegisterNetEvent('qb-anpr:server:flagVehicle', function(plate, reason, priority, notes)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or (Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'sheriff') then
        return
    end
    
    priority = math.max(1, math.min(5, priority or 1))
    plate = string.upper(plate)
    notes = notes or ''
    
    flaggedVehicles[plate] = {
        plate = plate,
        reason = reason,
        priority = priority,
        flaggedBy = Player.PlayerData.citizenid,
        dateAdded = os.date('%Y-%m-%d %H:%M:%S'),
        notes = notes
    }
    
    MySQL.Async.execute(
        'INSERT INTO anpr_flagged_vehicles (plate, reason, priority, flagged_by, date_added, notes) VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE reason = ?, priority = ?, flagged_by = ?, date_added = ?, notes = ?',
        { plate, reason, priority, Player.PlayerData.citizenid, flaggedVehicles[plate].dateAdded, notes, reason, priority, Player.PlayerData.citizenid, flaggedVehicles[plate].dateAdded, notes }
    )
    
    local officerName = GetPlayerName(Player.PlayerData.citizenid)
    TriggerClientEvent('QBCore:Notify', src, 
        string.format('🚨 Vehicle %s flagged on ANPR system\nReason: %s\nPriority: %d/5', plate, reason, priority), 
        'success', 5000
    )
    
    -- Log to console
    print(('[ANPR] Vehicle %s flagged by %s [%s] - Reason: %s, Priority: %d'):format(
        plate, officerName, Player.PlayerData.citizenid, reason, priority
    ))
end)

RegisterNetEvent('qb-anpr:server:unflagVehicle', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or (Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'sheriff') then
        return
    end
    
    plate = string.upper(plate)
    
    if flaggedVehicles[plate] then
        -- Remove from memory
        flaggedVehicles[plate] = nil
        
        -- Remove from database
        MySQL.Async.execute('DELETE FROM anpr_flagged_vehicles WHERE plate = ?', { plate })
        
        TriggerClientEvent('QBCore:Notify', src, 
            string.format('✅ Vehicle %s removed from ANPR system', plate), 
            'success', 3000
        )
        
        print(('[ANPR] Vehicle %s unflagged by %s [%s]'):format(
            plate, GetPlayerName(Player.PlayerData.citizenid), Player.PlayerData.citizenid
        ))
    else
        TriggerClientEvent('QBCore:Notify', src, 
            string.format('❌ Vehicle %s is not flagged on ANPR system', plate), 
            'error', 3000
        )
    end
end)

-- Check vehicle status
RegisterNetEvent('qb-anpr:server:checkVehicleStatus', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or (Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'sheriff') then
        return
    end
    
    plate = string.upper(plate)
    
    if flaggedVehicles[plate] then
        local flagData = flaggedVehicles[plate]
        local officerName = GetPlayerName(flagData.flaggedBy)
        
        TriggerClientEvent('qb-anpr:client:vehicleStatusResponse', src, {
            flagged = true,
            plate = plate,
            reason = flagData.reason,
            priority = flagData.priority,
            dateAdded = flagData.dateAdded,
            officerName = officerName,
            notes = flagData.notes
        })
    else
        TriggerClientEvent('qb-anpr:client:vehicleStatusResponse', src, {
            flagged = false,
            plate = plate
        })
    end
end)

-- PNC Search
RegisterNetEvent('qb-anpr:server:pncSearch', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or (Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'sheriff') then
        return
    end
    
    plate = string.upper(plate)
    
    if flaggedVehicles[plate] then
        local flagData = flaggedVehicles[plate]
        local officerName = GetPlayerName(flagData.flaggedBy)
        
        TriggerClientEvent('qb-anpr:client:pncSearchResponse', src, {
            flagged = true,
            plate = plate,
            reason = flagData.reason,
            priority = flagData.priority,
            dateAdded = flagData.dateAdded,
            officerName = officerName,
            notes = flagData.notes
        })
    else
        TriggerClientEvent('qb-anpr:client:pncSearchResponse', src, {
            flagged = false,
            plate = plate
        })
    end
end)