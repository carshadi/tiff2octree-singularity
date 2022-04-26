Bootstrap: docker
From: ubuntu:latest

%files
    bin/sbatch /bin/sbatch
    bin/scancel /bin/scancel
    bin/squeue /bin/squeue

%environment
    export PATH="/opt/miniconda3/bin:$PATH"
    export PATH="/opt/miniconda3/envs/octree/bin:$PATH"
    export PATH="/bin:$PATH"

%runscript
    exec "$@"

%post
    apt update &&
    apt install -y build-essential \
    wget \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    git \
    cmake \
    pkg-config \
    mesa-utils \
    libglu1-mesa-dev \
    freeglut3-dev \
    mesa-common-dev

    rm -rf /var/lib/apt/lists/*

    apt clean

    echo ". /opt/miniconda3/etc/profile.d/conda.sh" >> $SINGULARITY_ENVIRONMENT
    echo "conda activate octree" >> $SINGULARITY_ENVIRONMENT

    wget -c https://repo.anaconda.com/miniconda/Miniconda3-py39_4.11.0-Linux-x86_64.sh 
    /bin/bash Miniconda3-py39_4.11.0-Linux-x86_64.sh -bfp /opt/miniconda3
    . /opt/miniconda3/etc/profile.d/conda.sh
    conda update conda

    git clone https://github.com/JaneliaSciComp/pyktx.git
    git clone https://github.com/JaneliaSciComp/tiff2octree.git
    conda env create -f tiff2octree/environment.yml -p /opt/miniconda3/envs/octree
    conda activate octree
    pip install pyktx/

    chmod -R 755 /bin/s*



