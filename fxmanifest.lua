fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'QBCore ANPR System for British Police'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/menu.lua',
    'client/detection.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/flagging.lua',
    'server/detection.lua'
}

-- UI files
ui_page 'html/index.html'  -- Points to your main HTML file

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    -- add any assets you use, like fonts or images:
    -- 'html/assets/*.png',
}
dependencies {
    'qb-core',
    'qb-menu',
    'qb-input',
    'oxmysql'
}
