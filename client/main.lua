-- qb-anpr/client/main.lua
local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local anprCameras = {}
local anprBlips = {}
local flaggedVehicles = {}
local isPolice = false

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    checkPoliceJob()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    checkPoliceJob()
end)

function checkPoliceJob()
    if PlayerData.job and (PlayerData.job.name == 'police' or PlayerData.job.name == 'sheriff') then
        isPolice = true
    else
        isPolice = false
        -- Remove ANPR blips if not police
        for k, v in pairs(anprBlips) do
            RemoveBlip(v)
        end
        anprBlips = {}
    end
end

-- ANPR Camera Management
RegisterNetEvent('qb-anpr:client:deployCamera', function()
    if not isPolice then
        QBCore.Functions.Notify('You are not authorised to use this equipment', 'error')
        return
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    QBCore.Functions.Progressbar('deploy_anpr', 'Deploying ANPR Camera Unit...', 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'amb@world_human_hammering@male@base',
        anim = 'base',
        flags = 49,
    }, {}, {}, function()
        TriggerServerEvent('qb-anpr:server:deployCamera', coords, heading)
        ClearPedTasksImmediately(ped)
    end, function()
        ClearPedTasksImmediately(ped)
    end)
end)

RegisterNetEvent('qb-anpr:client:removeCamera', function()
    if not isPolice then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    for k, camera in pairs(anprCameras) do
        local dist = #(coords - vector3(camera.x, camera.y, camera.z))
        if dist < 3.0 then
            QBCore.Functions.Progressbar('remove_anpr', 'Packing up ANPR Camera Unit...', 3000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = 'amb@world_human_welding@male@base',
                anim = 'base',
                flags = 49,
            }, {}, {}, function()
                TriggerServerEvent('qb-anpr:server:removeCamera', k)
                ClearPedTasksImmediately(ped)
            end, function()
                ClearPedTasksImmediately(ped)
            end)
            break
        end
    end
end)

-- Update cameras from server
RegisterNetEvent('qb-anpr:client:updateCameras', function(cameras)
    anprCameras = cameras
    
    if isPolice then
        -- Remove old blips
        for k, v in pairs(anprBlips) do
            RemoveBlip(v)
        end
        anprBlips = {}
        
        -- Create new blips
        for k, camera in pairs(anprCameras) do
            local blip = AddBlipForCoord(camera.x, camera.y, camera.z)
            SetBlipSprite(blip, 184)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 17) -- British police blue
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('ANPR Camera')
            EndTextCommandSetBlipName(blip)
            anprBlips[k] = blip
        end
    end
end)

-- Commands
RegisterCommand('deployANPR', function()
    TriggerEvent('qb-anpr:client:deployCamera')
end)

RegisterCommand('removeANPR', function()
    TriggerEvent('qb-anpr:client:removeCamera')
end)

RegisterCommand('anpr', function()
    if isPolice then
        TriggerEvent('qb-anpr:client:openMainMenu')
    end
end)

-- Key Mappings
RegisterKeyMapping('deployANPR', 'Deploy ANPR Camera', 'keyboard', '')
RegisterKeyMapping('removeANPR', 'Remove ANPR Camera', 'keyboard', '')
RegisterKeyMapping('anpr', 'Open ANPR System', 'keyboard', '')