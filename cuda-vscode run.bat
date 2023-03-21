@echo off

REM Docker 설치 유무 확인
if not exist "%ProgramFiles%\Docker\Docker\resources\bin\docker.exe" (
    echo Docker가 설치되어 있지 않습니다. Docker를 먼저 설치해주세요.
    pause
    exit
)

REM Docker 이미지 확인 및 다운로드
docker inspect cuda-vscode > nul 2>&1 || docker pull nvidia/cuda:11.4.1-devel-ubuntu20.04

set CONTAINER_NAME=cuda-workspace
set IMAGE_NAME=cuda-vscode

REM 실행중인 Docker 컨테이너 검색
set EXISTING_CONTAINER=
for /f "delims=" %%i in ('docker ps -aq -f "name=%CONTAINER_NAME%"') do set EXISTING_CONTAINER=%%i

REM Docker 컨테이너 실행
if not "%EXISTING_CONTAINER%"=="" (
  echo Container already exists. Running existing container %CONTAINER_NAME%...
  docker start %EXISTING_CONTAINER%
) else (
  set /p PORT="Enter port number: "
  echo Creating new container %CONTAINER_NAME%...
  docker run -it --gpus all --name %CONTAINER_NAME% -p %PORT%:8080 %IMAGE_NAME%
)

pause