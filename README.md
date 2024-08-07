문서정보 : 2023.03.20. 작성, 작성자 [@SAgiKPJH](https://github.com/SAgiKPJH)  
문서 추가 업데이트 : 2023.09.30. ~ 10.02.


<br>

### 바로 사용하기
```bash
docker run -it --gpus all -p 18081:8080 -d juhyung1021/nvidia_cuda_cpp_vscode_docker_gpupu_programming:12.5.1
docker run -it --gpus all -p 18082:8080 -d juhyung1021/nvidia_cuda_cpp_vscode_docker_cpp_deeplearning:12.5.1

# or

nvidia-docker run -it -p 18081:8080 -d juhyung1021/nvidia_cuda_cpp_vscode_docker_gpupu_programming:12.5.1
nvidia-docker run -it -p 18082:8080 -d juhyung1021/nvidia_cuda_cpp_vscode_docker_cpp_deeplearning:12.5.1

# Cuda 버전이 안맞으면, 다른 버전을 활용할 수 있습니다., tag number = cuda version
```


<br>

# Docker_NVIDIA_VSCODE_CUDA_CPP
NVIDIA CUDA C++ In Docker Container, 도커 환경에서 vscode cuda c++를 수행할 수 있는 컨테이너를 제작한다.  
이를 통해 cuda c++을 도커가 존재하는 모든 환경에서 코딩할 수 있도록 구성한다.

![image](https://user-images.githubusercontent.com/66783849/226588071-9716fecf-061e-47f2-9af8-0d8892104552.png)


### 목표
- [x] : [1. Dockerfile 구성](#1-dockerfile-구성)
- [x] : [2. Dockerfile 빌드](#2-dockerfile-빌드)
- [x] : [3. DockerHub에 등록](#3-dockerhub에-등록)
- [x] : [4. Docker 실행](#4-docker-실행)
- [x] : [5. NDIVIA CUDA c++ Docker Test - Mandelbrot Set](#5-ndivia-cuda-c-docker-test---mandelbrot-set)
- [x] : [6. GPU 연결 확인 및 GPU 사용량 확인](#6-gpu-연결-확인-및-gpu-사용량-확인)
- [x] : [7. 다른 환경에서 Docker Test](#7-다른-환경에서-docker-test)
- [x] : [8. Git 활용하도록 개선](#8-git-활용하도록-개선)

### Error
- [x] [Docker Error - cuda version Error](#docker-error---cuda-version-error)

<br>

### 제작자
[@SAgiKPJH](https://github.com/SAgiKPJH)



<br>

---


# 1. Dockerfile 구성

- 다음과 같이 dockerfile을 구성한다. (YOUR_PASSWORD를 통해 비밀번호를 바꾼다)
  ```dockerfile
  # Base image
  FROM nvidia/cuda:11.4.1-devel-ubuntu20.04
  
  # Set working directory
  WORKDIR /workspace
  
  # Install necessary packages
  RUN apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y \
      build-essential \
      curl \
      git \
      wget \
      vim \
      && \
      rm -rf /var/lib/apt/lists/*
  
  # Install VSCode
  RUN curl -fsSL https://code-server.dev/install.sh | sh
  
  # Install Remote Development extension
  RUN /usr/bin/code-server --install-extension ms-vscode-remote.vscode-remote-extensionpack
  
  # Set environment variables
  ENV PATH="/usr/local/cuda-11.4/bin:${PATH}"
  ENV LD_LIBRARY_PATH="/usr/local/cuda-11.4/lib64:${LD_LIBRARY_PATH}"
  
  # Set the root password for VSCode
  RUN echo "root:root" | chpasswd && \
      sed -i 's|password:.*|password: root|g' ~/.config/code-server/config.yaml
  
  # Expose code-server port
  EXPOSE 8080
  
  # Start code-server
  CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "."]
  ```

<br>


# 2. Dockerfile 빌드

- 다음과 같이 dockerfile을 빌드한다.  
  ```bash
  docker build -t cuda-vscode .
  ```
  ![image](https://user-images.githubusercontent.com/66783849/226215743-067f872f-4ab6-4104-b9c6-b689d5359206.png)
  
<br>
  

# 3. DockerHub에 등록

- 이미지에 태그를 추가한다.
  ```bash
  docker tag cuda-vscode:latest username/imagename:version
  ```
- 다음과 같이 DockerHub에 등록한다.
  ```bash
  docker login
  docker push username/imagename:version
  ```
  ![image](https://user-images.githubusercontent.com/66783849/226217999-dca085e4-3fe1-415a-aafc-51ca81cdd23c.png)

<br>


# 4. Docker 실행

- 다음과 같이 docker를 run 한 후, `localhost:8080`으로 vscode에 접속한다. (password : YOUR_PASSWORD)
  ```bash
  docker run -it --gpus all --name cuda-workspace -p 8080:8080 cuda-vscode
  
  # 다른 port에 열기를 원하는 경우 다음과 같이 localhost:9090에 접속할 수 있다.
  docker run -it --gpus all --name cuda-workspace -p 9090:8080 cuda-vscode
  ```
- 이미 종료된 container를 다시 여는 경우는 다음과 같이 구성한다.
  ```bash
  docker start cuda-vscode
  ```
- 만일 vscode의 비밀번호를 모르겠으면, 실행중인 contatiner에 접속하여 다음과 같은 명령어를 입력하여 비밀번호를 확인한다.
  ```bash
  # docker ps 명령을 사용하여 실행 중인 컨테이너 ID를 확인
  docker ps
  
  # 컨테이너 내부의 bash 셸을 실행
  docker exec -it [container-id] bash
  
  # 비밀번호 확인
  cat ~/.config/code-server/config.yaml | grep password
  ```
- exe 형식으로 구성하려면, 다음과 같이 bat를 구성한다.  
  ![image](https://user-images.githubusercontent.com/66783849/226222086-cdf2ceab-2cd7-4bd0-bfdd-fc0a33e80f17.png)  
  ```bach
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
  ```
  ![image](https://user-images.githubusercontent.com/66783849/226219809-a5ef9fa4-86e0-479f-a00f-95a5747dd37c.png)  
  ![image](https://user-images.githubusercontent.com/66783849/226219831-52d1109b-ab7a-4ee7-898d-3186b05c0286.png)

<br>

#  5. NDIVIA CUDA c++ Docker Test - Mandelbrot Set

- 다음과 같이 Mandelbrot Set 이미지를 출력하는 예제를 구성한다.
  ```cuda
  #include <stdio.h>
  #include <stdlib.h>
  #include <stdint.h>
  #include <cuda.h>
  
  #define WIDTH 800
  #define HEIGHT 800
  #define MAX_ITERATIONS 255
  
  __global__ void mandelbrotKernel(uint8_t *img, double xmin, double ymin, double xmax, double ymax, double dx, double dy) {
      int i = threadIdx.x + blockIdx.x * blockDim.x;
      int j = threadIdx.y + blockIdx.y * blockDim.y;
      double x = xmin + i * dx;
      double y = ymin + j * dy;
      double zr = x;
      double zi = y;
      int k;
      for (k = 0; k < MAX_ITERATIONS; k++) {
          if (zr * zr + zi * zi > 4.0) break;
          double tmp = zr * zr - zi * zi + x;
          zi = 2.0 * zr * zi + y;
          zr = tmp;
      }
      img[i + j * WIDTH] = k;
  }
  
  int main(void) {
      uint8_t *img = (uint8_t*)malloc(WIDTH * HEIGHT * sizeof(uint8_t));
      uint8_t *dev_img;
      double xmin = -2.0;
      double ymin = -2.0;
      double xmax = 2.0;
      double ymax = 2.0;
      double dx = (xmax - xmin) / WIDTH;
      double dy = (ymax - ymin) / HEIGHT;
      cudaMalloc(&dev_img, WIDTH * HEIGHT * sizeof(uint8_t));
      dim3 blockDim(16, 16);
      dim3 gridDim((WIDTH + blockDim.x - 1) / blockDim.x, (HEIGHT + blockDim.y - 1) / blockDim.y);
      mandelbrotKernel<<<gridDim, blockDim>>>(dev_img, xmin, ymin, xmax, ymax, dx, dy);
      cudaMemcpy(img, dev_img, WIDTH * HEIGHT * sizeof(uint8_t), cudaMemcpyDeviceToHost);
      FILE *fp = fopen("mandelbrot.pgm", "wb");
      fprintf(fp, "P5\n%d %d\n%d\n", WIDTH, HEIGHT, 255);
      fwrite(img, sizeof(uint8_t), WIDTH * HEIGHT, fp);
      fclose(fp);
      free(img);
      cudaFree(dev_img);
      return 0;
  }
  ```
- 다음과 같이 컴파일을 진행한다.
  ```bash
  nvcc -o name main.cu
  ```
- 다음과 같이 프로그램을 실행한다.
  ```bash
  ./name
  ```
  ![image](https://user-images.githubusercontent.com/66783849/226223357-9952a193-842a-4d86-bbc6-adfc089f6805.png)  
- mandelbrot.ppm 이미지를 확인한다.
  ![image](https://user-images.githubusercontent.com/66783849/226223594-060c114d-8379-40c9-a565-c4b658c24d0c.png)  
  ![image](https://user-images.githubusercontent.com/66783849/226223691-66157937-ef39-4e72-9594-566578b33c29.png)

<br>

# 6. GPU 연결 확인 및 GPU 사용량 확인

- GPU 연결 확인 방법은 다음과 같다. vscode에서 바로 실행해볼 수 있다.
  ```bash
  nvidia-smi
  ```
  ![image](https://user-images.githubusercontent.com/66783849/226227983-b6677afd-581d-4f8f-bb0b-1bb901f2d86d.png)
- 보다 자세한 정보는 다음과 같이 확인할 수 있다.
  ```bash
  nvidia-smi -q
  ```
  ![image](https://user-images.githubusercontent.com/66783849/226228045-7a9c7d9d-6d46-42f9-88f6-c0bfeebaf0cb.png)
- GPU 사용량을 실시간으로 확인할려면, 다음과 같이 할 수 있다.
  ```bash
  watch -d -n 1 nvidia-smi
  ```
  ![image](https://user-images.githubusercontent.com/66783849/226228163-b22480e7-ae55-4d27-9019-eb3cee13e815.png)
- 이를 통해 프로그램을 실행 한 후, gpu 사용량을 확인해볼 수 있다.
  ![image](https://user-images.githubusercontent.com/66783849/226228268-c10f8268-5781-4281-8f10-b3235830a12c.png)  
  ![image](https://user-images.githubusercontent.com/66783849/226228382-9b7ef668-5941-48f7-9448-d907933ce304.png)

  
<br>

# 7. 다른 환경에서 Docker Test

- 다른 Window 및 Linux 환경에서 Test를 진행해 보았다.
  
<br>

# 8. Git 활용하도록 개선

- [CUDA_GPUPU_PROGRAMMING](https://github.com/SagiK-Repository/CUDA_GPUPU_Programming), [CUDA_CPP_DeepLearning](https://github.com/SagiK-Repository/CUDA_CPP_DeepLearning)을 각각 git으로 받아 활용할 수 있도록 구성합니다.
- [Docker_Tensorflow_Repository](https://github.com/SagiK-Repository/Docker_Tensorflow_Repository)에서 했던 내용을 참고하여 구성합니다.
- dockerfile을 다음과 같이 업데이트 합니다.
  ```dockerfile
  # Git clone & Start code-server
  CMD git clone https://github.com/SagiK-Repository/CUDA_CPP_DeepLearning.git /workspace && \
      code-server --bind-addr 0.0.0.0:8080 .
  ```
- 그러면 실행과 동시에 git 최신 정보와 함께 작업을 할 수 있습니다.


<br>

# Docker Error - cuda version Error

- 다음과 같이 CUDA Version이 안맞아서 생기는 문제가 존재합니다.
```error
docker: Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: 
runc create failed: unable to start container process: error during container init: error running hook #0: error running hook: exit status 1, stdout: , stderr: Auto-detected mode as 'legacy'
nvidia-container-cli: requirement error: unsatisfied condition: cuda>=12.2, please update your driver to a newer version, or use an earlier cuda container: unknown.
```
- 이는 [CUDA WIKI](https://www.wikiwand.com/en/CUDA#/GPUs_supported) 사이트를 통해 자신의 GPU 장치와 CUDA 버전을 자세히 확인합니다.
- 그리고 [NVIDIA CUD Developer](https://developer.nvidia.com/cuda-downloads?target_os=Windows&target_arch=x86_64&target_version=10) 사이트를 통해 CUDA 버전을 설치합니다. 이때 로그인해서 설치해야 합니다.
- 마지막으로 설치가 안될 시, Visual Studio Integration, Nsight VSE를 사용자 정의 설치에서 제외해서 설치 진행해야 합니다.
- 자세한 과정은 [Docker Error](https://github.com/SagiK-Repository/Docker_NVIDIA_VSCODE_CUDA_CPP/issues/1) Issue의 이슈 해결과정을 따라해 보십시오.
