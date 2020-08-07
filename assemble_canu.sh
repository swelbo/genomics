#!/bin/bash
#PBS -lselect=1:ncpus=1:mem=64gb
#PBS -lwalltime=24:00:00

# load modules 
module load java
module load canu/1.9

# SMART RUNS 
iso=(E01_1 F01_1 G01_1 H01_1)

reads=()
for i in "${iso[@]}"; do
    reads+=(/rds/general/user/tsewell/projects/fisher-bd-rawdata/live/pacbio/raw-files/IA042_59/${i}/Analysis_Results/*.fastq)
done

args=$(printf "%s " ${reads[@]})

# run canu
canu -p IA042 -d /rds/general/user/tsewell/projects/fisher-bd-results/live/pacbio/canu/IA042 genomeSize=27m -pacbio-raw $args
