ARG APP_IMAGE=continuumio/miniconda3:24.7.1-0
FROM ${APP_IMAGE}
ARG APP_IMAGE
ENV PATH="/opt/conda/envs/infinigen/bin:/opt/conda/bin:/root/miniconda3/envs/infinigen/bin:/root/miniconda3/bin:${PATH}"
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

RUN pip install --no-cache-dir "numpy<2" "scipy" "pyyaml" "google-cloud-storage" "h5py" || true

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

WORKDIR /workspace
COPY src ./src
COPY subsystems ./subsystems
