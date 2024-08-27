# Base CUDA image
#FROM cnstark/pytorch:2.0.1-py3.9.17-cuda11.8.0-ubuntu20.04
FROM registry.cn-beijing.aliyuncs.com/modelscope-repo/modelscope:ubuntu20.04-cuda11.8.0-py38-torch2.0.1-tf2.13.0-1.9.5

LABEL maintainer="breakstring@hotmail.com"
LABEL version="dev-20240209"
LABEL description="Docker image for GPT-SoVITS"


# Install 3rd party apps
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata ffmpeg libsox-dev parallel aria2 git git-lfs && \
    git lfs install && \
    rm -rf /var/lib/apt/lists/*

# Copy only requirements.txt initially to leverage Docker cache
WORKDIR /workspace
COPY requirements.txt /workspace/
RUN pip install --no-cache-dir -r requirements.txt && pip uninstall -y utils tools

COPY nltk_data /opt/conda/nltk_data

# Define a build-time argument for image type
ARG IMAGE_TYPE=full

# Conditional logic based on the IMAGE_TYPE argument
# Always copy the Docker directory, but only use it if IMAGE_TYPE is not "elite"
#COPY ./Docker /workspace/Docker
# elite 类型的镜像里面不包含额外的模型
#RUN if [ "$IMAGE_TYPE" != "elite" ]; then \
#        chmod +x /workspace/Docker/download.sh && \
#        /workspace/Docker/download.sh && \
#        python /workspace/Docker/download.py && \
#        python -m nltk.downloader averaged_perceptron_tagger cmudict; \
#    fi


# Copy the rest of the application
COPY . /workspace

# 确保容器里面可以调用GPU
ENV CUDA_DEVICE_ORDER="PCI_BUS_ID" \
    PYTORCH_NVML_BASED_CUDA_CHECK=1 \
    CUDA_VISIBLE_DEVICES=0,1

EXPOSE 9871 9872 9873 9874 9880

#CMD ["python", "webui.py"]
CMD sh -c 'pip install jupyterlab && jupyter lab --ip=0.0.0.0 --port=8888 --ServerApp.token=cloud52128 --allow-root'