#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=8gb
#PBS -lwalltime=12:00:00

# modules
module load anaconda3/personal

# index array
i=$PBS_ARRAY_INDEX

# Expand a space-sperated parameter of file names into addressable array
reads1=(${args1})
reads2=(${args2})

# absolute path to reads 
READS=("${reads1[$i]}" "${reads2[$i]}")
#READS2=("${reads2[$i]}")

# sample name
out1=$( basename ${READS[0]} )
out2=$( basename ${READS[1]} )

cutadapt -a "$ADAPTER_FWD" -A "$ADAPTER_REV" --minimum-length 25 --trim-n -q 20,20 -o "${trimout}/${out1%%.*}.trimmed.fastq.gz" -p "${trimout}/${out2%%.*}.trimmed.fastq.gz" "${READS[0]}" "${READS[1]}"
