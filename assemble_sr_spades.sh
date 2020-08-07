#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=32gb
#PBS -lwalltime=48:00:00

## Spades single read short genome only

# load modules
module load anaconda3/personal
#module load spades/3.10.1

# index array 
i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
read1=(${args1})
read2=(${args2})

# output location
assout=(${args3})

# Spades command
spades.py --isolate -k 21,33,55,77 -t 8 --pe1-1 "${read1[i]}" --pe1-2 "${read2[i]}" -o "${assout[i]}"