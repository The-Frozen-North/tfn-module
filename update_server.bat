del /f server\config\common.env
del /f server\modules\and_the_Wailing_Death.mod
del /f server\settings.tml
rmdir /s /q  server\override
copy modules\and_the_Wailing_Death.mod server\modules\and_the_Wailing_Death.mod
copy config\common.env server\config\common.env
copy settings.tml server\settings.tml
robocopy override server\override
PAUSE