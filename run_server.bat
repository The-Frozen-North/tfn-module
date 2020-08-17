del /f server\config\common.env
del /f server\modules\and_the_Wailing_Death.mod
del /f server\settings.tml
rmdir /s /q  server\override
copy devserver\modules\and_the_Wailing_Death.mod server\modules\and_the_Wailing_Death.mod
copy devserver\config\common.env server\config\common.env
copy devserver\settings.tml server\settings.tml
robocopy devserver\override server\override
cd server & docker-compose up --no-recreate
PAUSE