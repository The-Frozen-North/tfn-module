@echo off
IF NOT EXIST .build\modules\TFN.mod (
    echo .build\modules\TFN.mod does not exist. Please run win_nasher_install.bat first to install the module
    pause
    exit /b 1
)

docker --version > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Docker is not installed. Please install Docker to run the server.
    pause
    exit /b 1
)

docker info > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Docker error encountered or the Docker service isn't running! Please check and try again.
    pause
    exit /b 1
)

cd .build

docker-compose -f docker-compose-dev.yml down
docker-compose -f docker-compose-dev.yml up --no-recreate -d