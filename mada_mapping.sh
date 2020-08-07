#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=32gb
#PBS -lwalltime=12:00:00

# load modules
module load bwa
module load samtools
module load picard

# reference sequence
ref=/rds/general/user/tsewell/projects/fisher-bd-reference/live/Bd_JEL423_v1/batrachochytrium_dendrobatidis_jel423_mitochondrial_assembly_1_1_contigs.fasta

# #  Kihansi shotgun read data 
read=${read}

# output folder 
output="/rds/general/user/tsewell/projects/fisher-chytrid-results/live/output"

# header 1
fcid=$(echo ${read[$i]##*/} | cut -d_ -f4 )
lane=$(echo ${read[$i]##*/} | cut -d_ -f5 )
sample=$(echo ${read[$i]##*/} | cut -d_ -f6 )
lib="madashotgun_feb2019"
RG="@RG\tID:${fcid}.${lane}\tSM:${sample}\tPL:ILLUMINA\tLB:${lib}"

# read mapping
bwa mem -t 8 -R $RG $ref ${read} > $output/output_${fcid}.${sample}.${lane}.sam

# sam > bam
samtools view -S -b $output/output_${fcid}.${sample}.${lane}.sam > $output/output_${fcid}.${sample}.${lane}.bam

# sort sam
samtools sort -O bam -T /rds/general/user/tsewell/projects/fisher-chytrid-results/ephemeral/ $output/output_${fcid}.${sample}.${lane}.bam > $output/output_${fcid}.${sample}.${lane}.sorted.bam

# index samfile
samtools index $output/output_${fcid}.${sample}.${lane}.sorted.bam

# mark duplicates
#java -jar /apps/picard/2.6.0/picard.jar MarkDuplicates VALIDATION_STRINGENCY=LENIENT INPUT="$output/output_${fcid}.${sample}.${lane}.sorted.bam" OUTPUT="$output/output_${fcid}.${sample}.${lane}.sorted.mkdup.bam" METRICS_FILE="$output/output_${fcid}.${sample}.${lane}.metrics"

#samtools index $output/output_${fcid}.${sample}.${lane}.sorted.mkdup.bam

#MIN_COVERAGE_DEPTH=5

#samtools mpileup output_AKF18.S4.A.sorted.mkdup.bam | awk -v X="${MIN_COVERAGE_DEPTH}" '$4>=X' | wc -l

#Size of the mitocondrial genome (bp)
#174115


