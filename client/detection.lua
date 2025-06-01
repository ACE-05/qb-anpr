-- qb-anpr/client/detection.lua
local QBCore = exports['qb-core']:GetCoreObject()

-- ANPR Detection System
CreateThread(function()
    while true do
        Wait(1000)
        
        if #anprCameras > 0 then
            local ped = PlayerPedId()
            
            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                local plate = QBCore.Functions.GetPlate(vehicle)
                local vehCoords = GetEntityCoords(vehicle)
                
                for k, camera in pairs(anprCameras) do
                    local cameraCoords = vector3(camera.x, camera.y, camera.z)
                    local dist = #(vehCoords - cameraCoords)
                    
                    if dist < 15.0 then
                        -- Check if this plate detection was already sent recently
                        if not camera.lastDetected or camera.lastDetected ~= plate or (GetGameTimer() - (camera.lastDetectionTime or 0)) > 30000 then
                            TriggerServerEvent('qb-anpr:server:vehicleDetected', plate, k, vehCoords)
                            camera.lastDetected = plate
                            camera.lastDetectionTime = GetGameTimer()
                        end
                    end
                end
            end
        end
    end
end)

-- ANPR Alert Handler
RegisterNetEvent('qb-anpr:client:anprAlert', function(data)
    if not isPolice then return end
    
    -- Priority-based alert styling
    local alertColour = ''
    local alertSound = ''
    local alertType = 'inform'
    
    if data.priority >= 4 then
        alertColour = '🔴 CRITICAL ALERT'
        alertSound = 'TIMER_STOP'
        alertType = 'error'
    elseif data.priority >= 3 then
        alertColour = '🟠 HIGH PRIORITY'
        alertSound = 'CHECKPOINT_PERFECT'
        alertType = 'primary'
    elseif data.priority >= 2 then
        alertColour = '🟡 MEDIUM PRIORITY'
        alertSound = 'WAYPOINT_SET'
        alertType = 'primary'
    else
        alertColour = '🟢 LOW PRIORITY'
        alertSound = 'NAV_UP_DOWN'
        alertType = 'inform'
    end
    
    local alertText = string.format(
        '%s\n📋 Reg: %s\n📍 Location: %s\n⚠️ Reason: %s\n👮 Officer: %s',
        alertColour,
        data.plate,
        data.location,
        data.reason,
        data.officerName or 'Unknown'
    )
    
    QBCore.Functions.Notify(alertText, alertType, 10000)
    
    -- Set GPS waypoint for medium/high priority alerts
    if data.priority >= 2 then
        SetNewWaypoint(data.coords.x, data.coords.y)
        QBCore.Functions.Notify('📍 GPS waypoint set to detection location', 'success', 3000)
    end
    
    -- Play British-style alert sound
    PlaySoundFrontend(-1, alertSound, 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
    
    -- Log alert for recent alerts menu
    TriggerServerEvent('qb-anpr:server:logAlert', data)
end)

-- Vehicle Status Response
RegisterNetEvent('qb-anpr:client:vehicleStatusResponse', function(data)
    local statusText = ''
    
    if data.flagged then
        statusText = string.format(
            '🚨 VEHICLE FLAGGED\n📋 Reg: %s\n⚠️ Reason: %s\n📊 Priority: %d/5\n📅 Flagged: %s\n👮 By: %s',
            data.plate,
            data.reason,
            data.priority,
            data.dateAdded,
            data.officerName
        )
        QBCore.Functions.Notify(statusText, 'error', 8000)
    else
        statusText = string.format('✅ VEHICLE CLEAR\n📋 Reg: %s\nNo active flags on ANPR system', data.plate)
        QBCore.Functions.Notify(statusText, 'success', 5000)
    end
end)

-- PNC Search Response
RegisterNetEvent('qb-anpr:client:pncSearchResponse', function(data)
    local searchMenu = {
        {
            header = '🔍 PNC Search Results',
            txt = 'Registration: ' .. data.plate,
            isMenuHeader = true
        }
    }
    
    if data.flagged then
        searchMenu[#searchMenu + 1] = {
            header = '🚨 FLAGGED VEHICLE',
            txt = 'This vehicle is on the ANPR watchlist',
            disabled = true
        }
        searchMenu[#searchMenu + 1] = {
            header = '⚠️ Reason: ' .. data.reason,
            txt = 'Priority Level: ' .. data.priority .. '/5',
            disabled = true
        }
        searchMenu[#searchMenu + 1] = {
            header = '📅 Date Flagged',
            txt = data.dateAdded,
            disabled = true
        }
        searchMenu[#searchMenu + 1] = {
            header = '👮 Flagged By',
            txt = data.officerName,
            disabled = true
        }
        
        if data.notes and data.notes ~= '' then
            searchMenu[#searchMenu + 1] = {
                header = '📝 Additional Notes',
                txt = data.notes,
                disabled = true
            }
        end
    else
        searchMenu[#searchMenu + 1] = {
            header = '✅ VEHICLE CLEAR',
            txt = 'No flags found on ANPR system',
            disabled = true
        }
    end
    
    searchMenu[#searchMenu + 1] = {
        header = '❌ Close',
        params = {
            event = 'qb-menu:closeMenu'
        }
    }
    
    exports['qb-menu']:openMenu(searchMenu)
end)