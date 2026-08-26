ARG APP_IMAGE=continuumio/miniconda3:24.7.1-0
FROM ${APP_IMAGE}
ARG APP_IMAGE
RUN if [ "$APP_IMAGE" = "nvidia/cuda:12.0.0-devel-ubuntu22.04" ]; then \
    echo "Using CUDA image" && \
    apt-get update && \
    apt-get install -y unzip sudo git g++ libglm-dev libglew-dev libglfw3-dev libgles2-mesa-dev zlib1g-dev wget cmake vim libxi6 && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    mkdir /root/.conda && \
    bash Miniconda3-latest-Linux-x86_64.sh -b && \
    rm -f Miniconda3-latest-Linux-x86_64.sh && \
    apt-get install -y libxkbcommon-x11-0; \
else \
    echo "Using Conda image" && \
    apt-get update -yq && \
    apt-get install -yq cmake g++ libgles2-mesa-dev libglew-dev libglfw3-dev libglm-dev libxi6 sudo unzip vim zlib1g-dev && \
    apt-get install -y libxkbcommon-x11-0; \
fi

RUN mkdir -p /opt/infinigen
WORKDIR /opt/infinigen
COPY subsystems/infinigen .
RUN conda init bash && \
    . ~/.bashrc && \
    conda create --name infinigen python=3.11 -y && \
    conda activate infinigen && \
    conda install -y -c conda-forge \
        "numpy<2" \
        "scipy" \
        "scikit-image<0.20.0" \
        "scikit-learn<1.4.0" \
        "pandas" \
        "matplotlib" \
        "tqdm" \
        "networkx" \
        "pyyaml" \
        "h5py" \
        "google-cloud-storage" && \
    pip install -e ".[dev]" && \
    pip install google-cloud-storage pyyaml

ENV PATH="/opt/conda/envs/infinigen/bin:${PATH}"
RUN ln -sf /opt/conda/envs/infinigen/bin/python /opt/conda/bin/python && \
    ln -sf /opt/conda/envs/infinigen/bin/python3 /opt/conda/bin/python3 && \
    ln -sf /opt/conda/envs/infinigen/bin/pip /opt/conda/bin/pip && \
    ln -sf /opt/conda/envs/infinigen/bin/python /usr/bin/python && \
    ln -sf /opt/conda/envs/infinigen/bin/python3 /usr/bin/python3

WORKDIR /workspace
COPY src ./src
COPY subsystems ./subsystems
