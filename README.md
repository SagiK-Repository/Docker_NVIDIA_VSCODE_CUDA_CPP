문서정보 : 2023.03.20. 작성, 작성자 [@SAgiKPJH](https://github.com/SAgiKPJH)

<br>

# Docker_NVIDIA_VSCODE_CUDA_CPP
NVIDIA CUDA C++ In Docker Container, 도커 환경에서 vscode cuda c++를 수행할 수 있는 컨테이너를 제작한다.  
이를 통해 cuda c++을 도커가 존재하는 모든 환경에서 코딩할 수 있도록 구성한다.


### 목표
- [ ] : [1. Dockerfile 구성]
- [ ] : [2. Dockerfile 빌드]
- [ ] : [3. DockerHub에 등록]
- [ ] : [4. Docker 실행]
- [ ] : [Docker Test]
- [ ] : [다른 환경에서 Docker Test]

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
