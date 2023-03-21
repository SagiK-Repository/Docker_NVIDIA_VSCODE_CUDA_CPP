@echo off

set CONTAINER_NAME=nvidia_cuda_cpp_vscode_docker-workspace
set IMAGE_NAME=juhyung1021/nvidia_cuda_cpp_vscode_docker

echo %CONTAINER_NAME% container to %IMAGE_NAME%:lastest image

docker commit %CONTAINER_NAME% %IMAGE_NAME%:lastest

echo docker login

docker login

echo push %IMAGE_NAME%:lastest image
docker push %IMAGE_NAME%:lastest 

pause