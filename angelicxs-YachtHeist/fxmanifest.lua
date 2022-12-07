fx_version 'cerulean'
game 'gta5'

author 'AngelicXS'
description 'Yacht Heist'
version '1.0.1'

client_script {
    'client.lua',
}

server_script {
    'server.lua',
}

shared_script {
    'config.lua',
    -- '@es_extended/imports.lua',    --- Uncomment if using ESX
}

dependencies {
    'ps-ui',
    'xsound',
}
