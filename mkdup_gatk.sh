#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

# load modules
module load picard/2.6.0
module load java/jdk-8u66
module load samtools/1.3.1

# index array 
i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
bamlist=(${args})

# sample name
sample=$( basename ${bamlist[$i]} )

# output path fir mkdup bams 
bamout=${bamout}

# mark duplicates
#java -jar $PICARD_HOME/picard.jar MarkDuplicates \
	#INPUT="${bamlist[$i]}" \
	#TMP_DIR="${EPHEMERAL}" \
	#OUTPUT="${bamout}/${sample%%.*}/${sample%%.*}.mkdup.bam" \
	#CREATE_INDEX=TRUE \
	#METRICS_FILE="kihansi_output_${sample%%.*}.metrics"

# use this when you want to store all the bams in the same folder
java -jar $PICARD_HOME/picard.jar MarkDuplicates \
	INPUT="${bamlist[$i]}" \
	TMP_DIR="${EPHEMERAL}" \
	OUTPUT="${bamout}/${sample%%.*}.mkdup.bam" \
	CREATE_INDEX=TRUE \
	METRICS_FILE="kihansi_output_${sample%%.*}.metrics"