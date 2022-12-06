fx_version 'cerulean'
games { 'gta5' }

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
    '@es_extended/imports.lua',
    'config.lua'
}

dependencies {
    'ps-ui',
    'xsound',
}
