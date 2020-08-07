#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

# load modules
module load picard/2.6.0
module load java/jdk-8u66

# index array 
i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
bamlist=(${args})

# output path fir mkdup bams 
bamout=${bamout}

# meta data for read groups
sample=$( basename ${bamlist[$i]} )
id=$(echo ${bamlist[$i]##*/} | cut -d_ -f3 )
sm=$(echo ${bamlist[$i]##*/} | cut -d_ -f4 )
lane=$(echo ${bamlist[$i]##*/} | cut -d_ -f2 )
lib=${iam}

java -jar $PICARD_HOME/picard.jar AddOrReplaceReadGroups \
	INPUT="${bamlist[$i]}" \
	OUTPUT="${bamout}/${sample%%.*}.RG.bam" \
	RGID="${id}" \
	RGLB="${lib}" \
	RGPL="illumina" \
	RGPU="${lane}" \
	RGSM="${sm}" \
	CREATE_INDEX=TRUE \
	VALIDATION_STRINGENCY=SILENT
