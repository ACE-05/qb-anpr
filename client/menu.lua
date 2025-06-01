-- qb-anpr/client/menu.lua
local QBCore = exports['qb-core']:GetCoreObject()

-- Main ANPR Menu
RegisterNetEvent('qb-anpr:client:openMainMenu', function()
    local mainMenu = {
        {
            header = '🚔 ANPR Control System',
            txt = 'Metropolitan Police Service',
            isMenuHeader = true
        },
        {
            header = '📋 Vehicle Management',
            txt = 'Flag or unflag vehicles on the ANPR system',
            params = {
                event = 'qb-anpr:client:openVehicleMenu'
            }
        },
        {
            header = '📊 Active Cameras',
            txt = 'View and manage deployed ANPR cameras',
            params = {
                event = 'qb-anpr:client:viewCameras'
            }
        },
        {
            header = '🚨 Recent Alerts',
            txt = 'View recent ANPR detections and alerts',
            params = {
                event = 'qb-anpr:client:viewAlerts'
            }
        },
        {
            header = '📱 PNC Search',
            txt = 'Search Police National Computer records',
            params = {
                event = 'qb-anpr:client:pncSearch'
            }
        },
        {
            header = '❌ Close',
            params = {
                event = 'qb-menu:closeMenu'
            }
        }
    }
    
    exports['qb-menu']:openMenu(mainMenu)
end)

-- Vehicle Management Menu
RegisterNetEvent('qb-anpr:client:openVehicleMenu', function()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local vehicleText = 'No vehicle nearby'
    local plate = ''
    
    if vehicle ~= 0 then
        plate = QBCore.Functions.GetPlate(vehicle)
        vehicleText = 'Vehicle: ' .. plate
    end
    
    local vehicleMenu = {
        {
            header = '🚗 Vehicle Management',
            txt = vehicleText,
            isMenuHeader = true
        },
        {
            header = '🚨 Flag Vehicle',
            txt = 'Add vehicle to ANPR watchlist',
            disabled = vehicle == 0,
            params = {
                event = 'qb-anpr:client:flagVehicle',
                args = { plate = plate }
            }
        },
        {
            header = '✅ Unflag Vehicle',
            txt = 'Remove vehicle from ANPR watchlist',
            disabled = vehicle == 0,
            params = {
                event = 'qb-anpr:client:unflagVehicle',
                args = { plate = plate }
            }
        },
        {
            header = '🔍 Check Vehicle Status',
            txt = 'View current flag status',
            disabled = vehicle == 0,
            params = {
                event = 'qb-anpr:client:checkVehicleStatus',
                args = { plate = plate }
            }
        },
        {
            header = '🔙 Back',
            params = {
                event = 'qb-anpr:client:openMainMenu'
            }
        }
    }
    
    exports['qb-menu']:openMenu(vehicleMenu)
end)

-- Flag Vehicle Dialog
RegisterNetEvent('qb-anpr:client:flagVehicle', function(data)
    local dialog = exports['qb-input']:ShowInput({
        header = '🚨 Flag Vehicle - ' .. data.plate,
        submitText = 'Submit to ANPR Database',
        inputs = {
            {
                text = 'Reason for Flag',
                name = 'reason',
                type = 'text',
                isRequired = true,
                placeholder = 'e.g. Suspected stolen, No insurance, etc.'
            },
            {
                text = 'Priority Level (1-5)',
                name = 'priority',
                type = 'number',
                isRequired = true,
                placeholder = '1 = Low, 5 = Critical'
            },
            {
                text = 'Additional Notes',
                name = 'notes',
                type = 'text',
                isRequired = false,
                placeholder = 'Any additional information...'
            }
        }
    })
    
    if dialog and dialog.reason and dialog.priority then
        local priority = tonumber(dialog.priority)
        if priority and priority >= 1 and priority <= 5 then
            TriggerServerEvent('qb-anpr:server:flagVehicle', data.plate, dialog.reason, priority, dialog.notes or '')
        else
            QBCore.Functions.Notify('Priority must be between 1 and 5', 'error')
        end
    end
end)

-- Unflag Vehicle
RegisterNetEvent('qb-anpr:client:unflagVehicle', function(data)
    TriggerServerEvent('qb-anpr:server:unflagVehicle', data.plate)
end)

-- Check Vehicle Status
RegisterNetEvent('qb-anpr:client:checkVehicleStatus', function(data)
    TriggerServerEvent('qb-anpr:server:checkVehicleStatus', data.plate)
end)

-- PNC Search
RegisterNetEvent('qb-anpr:client:pncSearch', function()
    local dialog = exports['qb-input']:ShowInput({
        header = '🔍 PNC Search',
        submitText = 'Search Database',
        inputs = {
            {
                text = 'Registration Number',
                name = 'plate',
                type = 'text',
                isRequired = true,
                placeholder = 'Enter vehicle registration...'
            }
        }
    })
    
    if dialog and dialog.plate then
        TriggerServerEvent('qb-anpr:server:pncSearch', dialog.plate)
    end
end)

-- View Active Cameras
RegisterNetEvent('qb-anpr:client:viewCameras', function()
    TriggerServerEvent('qb-anpr:server:getCameraList')
end)

RegisterNetEvent('qb-anpr:client:showCameraList', function(cameras)
    local cameraMenu = {
        {
            header = '📊 Active ANPR Cameras',
            txt = 'Total: ' .. #cameras .. ' cameras deployed',
            isMenuHeader = true
        }
    }
    
    if #cameras == 0 then
        cameraMenu[#cameraMenu + 1] = {
            header = 'No cameras deployed',
            txt = 'Deploy cameras using the ANPR equipment',
            disabled = true
        }
    else
        for i, camera in ipairs(cameras) do
            local location = 'Location: ' .. math.floor(camera.x) .. ', ' .. math.floor(camera.y)
            cameraMenu[#cameraMenu + 1] = {
                header = '📹 Camera #' .. camera.id,
                txt = location,
                params = {
                    event = 'qb-anpr:client:setCameraWaypoint',
                    args = { coords = { x = camera.x, y = camera.y, z = camera.z } }
                }
            }
        end
    end
    
    cameraMenu[#cameraMenu + 1] = {
        header = '🔙 Back',
        params = {
            event = 'qb-anpr:client:openMainMenu'
        }
    }
    
    exports['qb-menu']:openMenu(cameraMenu)
end)

-- Set waypoint to camera
RegisterNetEvent('qb-anpr:client:setCameraWaypoint', function(data)
    SetNewWaypoint(data.coords.x, data.coords.y)
    QBCore.Functions.Notify('GPS set to camera location', 'success')
end)

-- View Recent Alerts
RegisterNetEvent('qb-anpr:client:viewAlerts', function()
    TriggerServerEvent('qb-anpr:server:getRecentAlerts')
end)

RegisterNetEvent('qb-anpr:client:showRecentAlerts', function(alerts)
    local alertMenu = {
        {
            header = '🚨 Recent ANPR Alerts',
            txt = 'Last 10 detections',
            isMenuHeader = true
        }
    }
    
    if #alerts == 0 then
        alertMenu[#alertMenu + 1] = {
            header = 'No recent alerts',
            txt = 'All quiet on the ANPR network',
            disabled = true
        }
    else
        for i, alert in ipairs(alerts) do
            local priorityText = ''
            if alert.priority >= 4 then
                priorityText = '🔴 HIGH PRIORITY'
            elseif alert.priority >= 2 then
                priorityText = '🟡 MEDIUM PRIORITY'
            else
                priorityText = '🟢 LOW PRIORITY'
            end
            
            alertMenu[#alertMenu + 1] = {
                header = alert.plate .. ' - ' .. priorityText,
                txt = alert.reason .. ' | ' .. alert.time,
                disabled = true
            }
        end
    end
    
    alertMenu[#alertMenu + 1] = {
        header = '🔙 Back',
        params = {
            event = 'qb-anpr:client:openMainMenu'
        }
    }
    
    exports['qb-menu']:openMenu(alertMenu)
end)