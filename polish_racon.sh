#!/bin/bash
#PBS -lselect=1:ncpus=1:mem=64gb
#PBS -lwalltime=24:00:00

#load modules
module load anaconda3/personal

# index array
i=$PBS_ARRAY_INDEX

# arguments 
reads=(${args1})
sam=(${args2})
ass=(${args3})

# output
output=(${args4})

# run racon command
~/racon/build/bin/racon "${reads[$i]}" "${sam[$i]}" "${ass[$i]}" > "${output[$i]}"