Config = {}

-- General Settings
Config.Framework = 'qb-core'
Config.Debug = false

-- Job Settings
Config.PoliceJobs = {
    'police',
    'sheriff'
}

-- ANPR Camera Settings
Config.CameraRange = 15.0 -- Detection range in meters
Config.CameraDetectionCooldown = 30000 -- 30 seconds between same plate detections
Config.MaxCamerasPerOfficer = 5 -- Maximum cameras one officer can deploy

-- Alert Settings
Config.AlertDuration = {
    [1] = 5000,  -- Low priority (5 seconds)
    [2] = 6000,  -- Medium-low priority (6 seconds)
    [3] = 8000,  -- Medium priority (8 seconds)
    [4] = 10000, -- High priority (10 seconds)
    [5] = 12000  -- Critical priority (12 seconds)
}

-- GPS Waypoint Settings
Config.AutoWaypointPriority = 2 -- Minimum priority level to auto-set GPS waypoint

-- Notification Sounds
Config.AlertSounds = {
    [1] = { name = 'NAV_UP_DOWN', set = 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
    [2] = { name = 'WAYPOINT_SET', set = 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
    [3] = { name = 'CHECKPOINT_PERFECT', set = 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
    [4] = { name = 'TIMER_STOP', set = 'HUD_MINI_GAME_SOUNDSET' },
    [5] = { name = 'TIMER_STOP', set = 'HUD_MINI_GAME_SOUNDSET' }
}

-- Blip Settings
Config.CameraBlip = {
    sprite = 184,
    color = 17, -- British police blue
    scale = 0.8,
    shortRange = true,
    name = 'ANPR Camera'
}

-- MODIFIED: Enhanced Items Configuration with Custom Models
Config.Items = {
    -- Standard ANPR Camera
    anpr_camera = {
        name = 'anpr_camera',
        label = 'ANPR Camera Unit',
        model = 'prop_cctv_cam_01a',
        range = 15.0,
        deployTime = 5000,
        animation = {
            dict = 'amb@world_human_hammering@male@base',
            anim = 'base',
            flags = 49
        }
    },
    
    -- Portable ANPR Scanner
    anpr_portable = {
        name = 'anpr_portable',
        label = 'Portable ANPR Scanner',
        model = 'prop_cctv_cam_02a',
        range = 12.0,
        deployTime = 3000,
        animation = {
            dict = 'amb@world_human_clipboard@male@base',
            anim = 'base',
            flags = 49
        }
    },
    
    -- Handheld ANPR Device
    anpr_handheld = {
        name = 'anpr_handheld',
        label = 'Handheld ANPR Device',
        model = 'prop_police_radio',
        range = 8.0,
        deployTime = 2000,
        animation = {
            dict = 'cellphone@',
            anim = 'cellphone_text_read_base',
            flags = 49
        }
    },
    
    -- Advanced ANPR System
    anpr_advanced = {
        name = 'anpr_advanced',
        label = 'Advanced ANPR System',
        model = 'prop_cctv_cam_04a',
        range = 20.0,
        deployTime = 8000,
        animation = {
            dict = 'amb@world_human_welding@male@base',
            anim = 'base',
            flags = 49
        }
    }
}

-- Street Names (you can expand this for better location names)
Config.StreetNames = {
    -- Add custom street names based on coordinates if desired
    -- Example: [vector3(x, y, z)] = "Custom Street Name"
}

-- Priority Levels
Config.PriorityLevels = {
    [1] = { name = 'Low', color = '🟢', description = 'Minor infractions, routine checks' },
    [2] = { name = 'Medium-Low', color = '🟡', description = 'Traffic violations, expired documents' },
    [3] = { name = 'Medium', color = '🟠', description = 'Suspected offences, investigation required' },
    [4] = { name = 'High', color = '🔴', description = 'Serious crimes, immediate response' },
    [5] = { name = 'Critical', color = '🚨', description = 'Armed/dangerous, all units respond' }
}

-- Command Settings
Config.Commands = {
    anpr = 'anpr',           -- Main ANPR menu
    deployAnpr = 'deployanpr', -- Deploy camera
    removeAnpr = 'removeanpr'  -- Remove camera
}

-- Permissions
Config.Permissions = {
    deploy = { 'police', 'sheriff' },
    flag = { 'police', 'sheriff' },
    unflag = { 'police', 'sheriff' },
    view = { 'police', 'sheriff' }
}
