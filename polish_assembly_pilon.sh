#!/bin/bash
#PBS -lselect=1:ncpus=16:mem=64gb
#PBS -lwalltime=24:00:00

# load modules
module load java/jdk-8u66
module load samtools/1.3.1
module load pilon/1.21

# index array 
i=$PBS_ARRAY_INDEX

## reference assembly (# out as necessary)
# single reference
#ref=${ref}

# multiple references - include this in ngmlr command: ("${assemblies[$i]}")
assemblies=(${args1})

# Expand a space-sperated parameter of file names into addressable array
bams=(${args2})

# output path fir mkdup bams 
pilonout=(${args3})

# job script
java -Xmx64G -jar $PILON_HOME/pilon-1.21.jar --genome "${assemblies[i]}" --frags "${bams[i]}" --output "${pilonout[i]}" --fix all --mindepth 0.5 --changes --verbose
