#!/bin/sh

## Loaded software ##
module load bwa/0.7.8
module load samtools/1.3.1
module load java/jdk-8u66
module load picard/2.6.0
module load gatk/3.6

## Path variable for software used ##
PATH=$PATH:/apps/bwa/0.7.8/bin/bwa:/apps/samtools/1.3.1/bin/samtools:/apps/picard/2.6.0/picard.jar:/apps/gatk/3.6/GenomeAnalysisTK.jar:/apps/java/jdk-8u66/bin/java

## Alignment ##
# BWA alignment #
/apps/bwa/0.7.8/bin/bwa mem -M /work/tsewell/Aspergillus/References/Aspergillus_fumigatus.CADRE.12.dna.toplevel.fa /work/tsewell/Aspergillus/fastqs/170309_K00166_0192_BHHMH3BBXX_6_TP-D7-012_TP-D5-006_1.fastq.gz /work/tsewell/Aspergillus/fastqs/170309_K00166_0192_BHHMH3BBXX_6_TP-D7-012_TP-D5-006_2.fastq.gz > /work/tsewell/Aspergillus/Output/Af293.sam
