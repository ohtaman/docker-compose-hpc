#!/bin/sh
#PBS -q workq
#PBS -l nodes=2:ppn=1
#PBS -l mem=2G

# qsubを実行したディレクトリに移動
cd "${PBS_O_WORKDIR:-$(pwd)}"

module load mpi
source .venv/bin/activate

mpirun python tune.py