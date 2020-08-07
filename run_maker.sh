#!/bin/bash

#PBS -lselect=1:ncpus=1:mem=64gb
#PBS -lwalltime=44:00:00

#load modules
module load anaconda3/personal

#load environment
conda init bash
source activate bio_env

# move into folder
cd /rds/general/user/tsewell/projects/fisher-bd-minion-results/live/thomas/maker/IA042

# run maker
maker
