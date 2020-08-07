#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

# load modules
module load gatk/3.6
module load java/jdk-8u66
module load samtools/1.3.1

# index array 
i=$PBS_ARRAY_INDEX

# path to reference genome
ref=${ref}

#  Expand a space-sperated parameter of file names into addressable array
bamlist=(${args})

# sample name
sample=$( basename ${bamlist[$i]} )

# output path fir mkdup bams 
bamout=${bamout}

java -jar -Djava.io.tmpdir=$EPHEMERAL $GATK_HOME/GenomeAnalysisTK.jar \
	-T RealignerTargetCreator \
	-R "${ref}" \
	-I "${bamlist[$i]}" \
	-o "${bamout}/${sample%%.*}/${sample%%.*}.indel.intervals"

java -jar $GATK_HOME/GenomeAnalysisTK.jar \
	-T IndelRealigner \
	-targetIntervals "${bamout}/${sample%%.*}/${sample%%.*}.indel.intervals" \
	-o "${bamout}/${sample%%.*}/${sample%%.*}.raw.bam" \
	-I "${bamlist[$i]}" \
	-R "${ref}"

samtools index "${bamout}/${sample%%.*}/${sample%%.*}.raw.bam"