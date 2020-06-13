rem AzureService.exe +set fs_game mods/escape  +set net_ip 0.0.0.0  +set sv_punkbuster 0 +map_rotate +set net_port 28960  +set ui_maxclients "64" +set dedicated 1 +exec escape.cfg
WindowsAzureGuestAgent.exe +set dedicated 2 +set sv_punkbuster 0 +set sv_maxclients 10 +set logfile 2 +set net_ip "10.0.0.6" +set net_port "2214" +exec server.cfg +exec mod.cfg +set fs_game mods/zom_db +map_rotate

rem +set developer 1 

rem +set developer_script 1