#!/bin/bash

######-l mem=16gb,walltime=24:00:00,ncpus=8

#PBS -lselect=1:ncpus=32:mem=124gb
#PBS -lwalltime=24:00:00

module load samtools/1.3.1
module load picard/2.6.0
module load java/jdk-8u66

#  Input parameter to this file should be bamlist,
#  which is space seperated string of all bam files
#  for processing.
bams=( ${bamlist} )
bam=${bams[$PBS_ARRAY_INDEX]}
sample=$( basename ${bam} .raw.bam )

#  Set threshold for optical duplicates based on pixel density according to Illumina pipeline
ODP=100
prog=`samtools view -H "${bam}" | egrep ^@PG | perl -nle 'print $& if m{(?<=CL:bwa )samse}'`

if [[ ! -z "$prog" ]]; then
	ODP=10
	#//Older pipelines have smaller tile coordinates//
fi

java -Xmx16g -jar "${PICARD_HOME}/picard.jar" MarkDuplicates \
	VALIDATION_STRINGENCY=LENIENT OPTICAL_DUPLICATE_PIXEL_DISTANCE="$ODP" \
	TMP_DIR=/rds/general/user/tsewell/projects/fisher-bd-results/live/markup_tmp \
	MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
	INPUT="$bam" OUTPUT="${bam%.raw.bam}.mkdup.bam" \
	METRICS_FILE="${bam%.bam}.mkdup.metrics"

# Re-index new bam file...
samtools index "${bam%.raw.bam}.mkdup.bam"
