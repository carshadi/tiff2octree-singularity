Bootstrap: docker
From: ubuntu:latest

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
    echo "conda activate /opt/miniconda3/envs/octree" >> $SINGULARITY_ENVIRONMENT

    wget -c https://repo.anaconda.com/miniconda/Miniconda3-py39_4.11.0-Linux-x86_64.sh 
    /bin/bash Miniconda3-py39_4.11.0-Linux-x86_64.sh -bfp /opt/miniconda3
    . /opt/miniconda3/etc/profile.d/conda.sh
    conda update conda

    git clone https://github.com/JaneliaSciComp/pyktx.git
    git clone https://github.com/JaneliaSciComp/tiff2octree.git
    conda env create -f tiff2octree/environment.yml -p /opt/miniconda3/envs/octree
    conda activate octree
    pip install pyktx/

    git clone https://github.com/carshadi/tiff2octree-singularity.git
    cd tiff2octree-singularity/
    cp bin/sbatch /bin/sbatch
    cp bin/scancel /bin/scancel
    cp bin/squeue /bin/squeue

    chmod -R 755 /bin/s*



