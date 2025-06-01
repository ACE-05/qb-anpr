-- qb-anpr/client/main.lua
local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local anprCameras = {}
local anprBlips = {}
local anprObjects = {}
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
        -- Remove ANPR objects
        for k, v in pairs(anprObjects) do
            DeleteObject(v)
        end
        anprObjects = {}
    end
end

-- MODIFIED: Handle ANPR item usage
RegisterNetEvent('qb-anpr:client:useAnprItem', function(itemType, itemConfig)
    if not isPolice then
        QBCore.Functions.Notify('You are not authorised to use this equipment', 'error')
        return
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    QBCore.Functions.Progressbar('deploy_anpr', 'Deploying ' .. itemConfig.label .. '...', itemConfig.deployTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = itemConfig.animation.dict,
        anim = itemConfig.animation.anim,
        flags = itemConfig.animation.flags,
    }, {}, {}, function()
        TriggerServerEvent('qb-anpr:server:deployCamera', coords, heading, itemType)
        ClearPedTasksImmediately(ped)
    end, function()
        ClearPedTasksImmediately(ped)
    end)
end)

-- MODIFIED: Camera deployment (now called from item usage)
RegisterNetEvent('qb-anpr:client:deployCamera', function()
    -- This is now handled by the item usage system
    QBCore.Functions.Notify('Use an ANPR device from your inventory', 'inform')
end)

RegisterNetEvent('qb-anpr:client:removeCamera', function()
    if not isPolice then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    for k, camera in pairs(anprCameras) do
        local dist = #(coords - vector3(camera.x, camera.y, camera.z))
        if dist < 3.0 then
            local itemConfig = Config.Items[camera.itemType or 'anpr_camera']
            
            QBCore.Functions.Progressbar('remove_anpr', 'Packing up ' .. (itemConfig.label or 'ANPR Camera') .. '...', 3000, false, true, {
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

-- MODIFIED: Update cameras with custom models
RegisterNetEvent('qb-anpr:client:updateCameras', function(cameras)
    anprCameras = cameras
    
    -- Remove old objects and blips
    for k, v in pairs(anprObjects) do
        DeleteObject(v)
    end
    anprObjects = {}
    
    if isPolice then
        -- Remove old blips
        for k, v in pairs(anprBlips) do
            RemoveBlip(v)
        end
        anprBlips = {}
        
        -- Create new objects and blips
        for k, camera in pairs(anprCameras) do
            -- Create camera object with custom model
            local model = camera.model or 'prop_cctv_cam_01a'
            local modelHash = GetHashKey(model)
            
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Wait(1)
            end
            
            local obj = CreateObject(modelHash, camera.x, camera.y, camera.z, false, false, false)
            SetEntityHeading(obj, camera.heading)
            FreezeEntityPosition(obj, true)
            SetEntityInvincible(obj, true)
            anprObjects[k] = obj
            
            -- Create blip
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
