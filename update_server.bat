del /f server\config\common.env
del /f server\modules\and_the_Wailing_Death.mod
del /f server\database\spawns.sqlite3
del /f server\database\treasures.sqlite3
del /f server\settings.tml
rmdir /s /q  server\override
copy modules\and_the_Wailing_Death.mod server\modules\and_the_Wailing_Death.mod
copy config\common.env server\config\common.env
copy settings.tml server\settings.tml
copy database\spawns.sqlite3 server\database\spawns.sqlite3
copy database\treasures.sqlite3 server\database\treasures.sqlite3
robocopy override server\override
PAUSE