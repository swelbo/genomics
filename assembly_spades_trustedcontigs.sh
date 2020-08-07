#!/bin/bash
#PBS -lselect=1:ncpus=48:mem=124gb
#PBS -lwalltime=12:00:00

# load modules
module load anaconda3/personal

# index array 
i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
reads1=(${args1})
reads2=(${args2})

# trusted contigs
trusted=(${args3})

# output location
assout=${assout}

# sample name
sample=$( basename $(dirname ${reads1[$i]}) )

# Spades command
spades.py --isolate -t 48 -1 "${reads1[$i]}" -2 "${reads2[$i]}" --untrusted-contigs "${trusted[$i]}" -o "${assout}/${sample}"
