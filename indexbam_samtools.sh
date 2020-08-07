#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

# load modules
module load samtools/1.3.1

# index array 
i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
bamlist=(${args})

# sample name
sample=$( basename ${bamlist[$i]} )

# job
samtools index "${bamlist[$i]}"