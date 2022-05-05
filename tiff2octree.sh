#!/bin/bash
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16GB
#SBATCH -p compute
#SBATCH -t 24:00:00

## --------------------------------------------
## Adjustable parameters
## --------------------------------------------

# Singularity image containing the tiff2octree.py module.
SIF=tiff2octree.sif
# fMOST sample directory 
INPUT_FILE=/bil/data/df/75/df75626840c76c15/mouseID_362191-191816/CH2
# Output octree directory
OUTPUT_FILE=/bil/proj/u19zeng/fMOST_octree/mouseID_362191-191816
# Channel ID (0 or 1)
CHANNEL=1
# Num threads to distribute the work
THREADS=64
# Voxel spacing for the fMOST sample (X,Y,Z). This will generally be
# found in the metainfo.txt file (if there is one).
VOXSIZE="0.35,0.35,1.0"
# Location of the top-left corner of the full volume in voxel coordinates (X,Y,Z),
# also in metainfo.txt.
ORIGIN="0,0,0"
# Scratch space for dask worker file spilling. This should be fast, node-local storage.
DASK_LOCAL_DIR="${DASK_LOCAL_DIR:-/tmp}"

## ---------------------------------------------
## Nothing below this point needs to be changed
## ---------------------------------------------

module purge
module load singularity

# Scheduler file - the Python code will need to refer to this
export SCHED_FILE=${SLURM_JOB_ID}.sched
echo "Writing scheduler file to ${PWD}/${SCHED_FILE}"

echo "Starting scheduler on node ${HOSTNAME}"

# Launch the scheduler.
# Adding --writable-tmpfs is necessary since conda needs to generate temporary files on the fly.
singularity run --bind /bil --bind $DASK_LOCAL_DIR --writable-tmpfs  \
$SIF dask-scheduler --scheduler-file=$SCHED_FILE  &

# Wait for scheulder to spin up before connecting workers
while ! [ -f $SCHED_FILE ]; do
    sleep 3
    echo -n .
done
echo 'Scheduler booted, launching worker and client'

# Memory per worker
export MEM=$((SLURM_CPUS_PER_TASK * SLURM_MEM_PER_CPU))

# Launch the worker processes using the SLURM-allocated resources
# It is critical that --no-nanny is set, otherwise we will oversubscribe allocated threads.
# This means that a worker will not be restarted if it dies, so be sure to check for failed tasks. 
srun singularity run --bind /bil --bind $DASK_LOCAL_DIR --writable-tmpfs \
$SIF dask-worker --local-directory=$DASK_LOCAL_DIR --no-nanny --nthreads=$SLURM_CPUS_PER_TASK \
--scheduler-file=$SCHED_FILE  --memory-limit=${MEM}M --death-timeout=600s &

# Start the client program
singularity run \
--bind /bil \
--bind $DASK_LOCAL_DIR \
--writable-tmpfs \
$SIF \
python /tiff2octree/tiff2octree.py \
-i $INPUT_FILE \
-l 5 \
-o $OUTPUT_FILE \
-c $CHANNEL \
-d 2ndmax \
--dtype uint16 \
--queue compute \
-t $THREADS \
--voxsize $VOXSIZE \
--origin $ORIGIN \
--ktx \
--monitor \
--scheduler-file $SCHED_FILE

# stop the workers
scancel ${SLURM_JOBID}.0
