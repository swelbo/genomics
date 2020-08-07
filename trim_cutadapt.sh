#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=8gb
#PBS -lwalltime=12:00:00

# modules
module load anaconda3/personal

# index array
i=$PBS_ARRAY_INDEX

# Expand a space-sperated parameter of file names into addressable array
reads=(${args})

# absolute path to reads 
READS=("${reads[$i]}")

# sample name
#sample=$(basename ${READS[0]})
out=$( basename ${READS[0]} )

# cutadapt command
cutadapt -f fastq -a "$adapter" --max-n 0.2 --minimum-length 25 --trim-n -q 20,20 -o "${trimout}/${out%%.*}.trimmed.fastq.gz" "${READS[0]}"




