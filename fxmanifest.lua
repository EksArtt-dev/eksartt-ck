fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'EksArtt'
description 'EksArtt Ck Sistem'

shared_scripts { 'config.lua', '@qb-core/shared/locale.lua', 
'locales/en.lua' -- İstediğiniz dile ayarlayın
}
server_script 'server/server.lua'
server_script 'server/backup.lua'