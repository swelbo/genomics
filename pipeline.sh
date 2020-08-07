#!/bin/sh

# Exit with message
die() { echo "$@" ; exit 1; }

# Check input files are specified
if [ $# != 3 ] ; then
        die "Usage: $0 <reads1.fastq.gz> <reads2.fastq.gz> <output id>"
fi

## Programs
FASTQ1=$1
FASTQ2=$2
ID=$3
SAMTOOLS="/apps/samtools/1.3.1/bin/samtools"
BWA="/apps/bwa/0.7.8/bin/bwa"
PICARD="/apps/picard/2.6.0/picard.jar"
GATK="/apps/gatk/3.6/GenomeAnalysisTK.jar"
java="/apps/java/jdk-8u66/bin/java"

## Folders
OUTPUT="/work/tsewell/Aspergillus/Output/$ID"
REF="/work/tsewell/Aspergillus/References"

mkdir "/work/tsewell/Aspergillus/Output/$ID" # create the directory where the files are to be written

## Alignment ##
# BWA alignment #
$BWA mem -M $REF/Aspergillus_fumigatus.CADRE.12.dna.toplevel.fa $FASTQ1 $FASTQ2 > $OUTPUT/$ID.sam

# SAM to BAM conversion #
$SAMTOOLS import $REF/Aspergillus_fumigatus.CADRE.12.dna.toplevel.fa.fai $OUTPUT/$ID.sam $OUTPUT/$ID.bam

# Remove SAM file
rm $OUTPUT/$ID.sam

# Sort BAM file based on positions in the Reference genome
$SAMTOOLS sort $OUTPUT/$ID.bam > $OUTPUT/$ID.sorted.bam

# Index sorted BAM file
$SAMTOOLS index $OUTPUT/$ID.sorted.bam

# Fix sorted BAM file so read groups are set correctly
$java -jar $PICARD AddOrReplaceReadGroups INPUT=$OUTPUT/$ID.sorted.bam OUTPUT=$OUTPUT/$ID.fixed.sorted.bam SORT_ORDER=coordinate RGID=K00166 RGLB=dnaseq RGPL=illumina RGSM='WGS' CREATE_INDEX=TRUE RGPU=unknown VALIDATION_STRINGENCY=SILENT

# Mark duplicated reads due to sequencing errors (duplicates could include false positives and would influence downstream variant vcalling)
$java -jar $PICARD MarkDuplicates INPUT=$OUTPUT/$ID.fixed.sorted.bam OUTPUT=$OUTPUT/$ID.sorted.marked.bam CREATE_INDEX=TRUE METRICS_FILE=$OUTPUT/$ID_picard_info.txt REMOVE_DUPLICATES=false ASSUME_SORTED=true VALIDATION_STRINGENCY=SILENT

## Local realignment around INDELs (prevents misalignment and incorrect variant and INDEL calls) - GATK suggest to exculde this from the pipeline
# Identify areas that require local realignment
$java -jar $GATK -T RealignerTargetCreator -R $REF/Aspergillus_fumigatus.CADRE.12.dna.toplevel.fa -I $OUTPUT/$ID.sorted.marked.bam -o $OUTPUT/$ID.indel.intervals

# Peform realignment
$java -jar $GATK -T IndelRealigner -targetIntervals $OUTPUT/$ID.indel.intervals -o $OUTPUT/$ID.indelRealigned.bam -I $OUTPUT/$ID.sorted.marked.bam -R $REF/Aspergillus_fumigatus.CADRE.12.dna.toplevel.fa

# Index realigned BAM file
$SAMTOOLS index $OUTPUT/$ID.indelRealigned.bam

## SNP calling ##
# HaplotypeCaller to identify SNPs and INDELS using Realigned BAM file as input - Excludes repeat region using RepeatMasker (file)
$java -jar $GATK -R $REF/Aspergillus_fumigatus.CADRE.12.dna.toplevel.fa -T HaplotypeCaller -I $OUTPUT/$ID.indelRealigned.bam -ploidy 1 -o $OUTPUT/$ID.raw_variants.vcf -stand_call_conf 30 -stand_emit_conf 30 -XL $REF/Aspergillus_fumigatus.CADRE.12.dna.toplevel.repeat.intervals

# HaplotypeCaller counts both SNPs and INDELS so we select variants as SNPs only
$java -jar $GATK -R $REF/Aspergillus_fumigatus.CADRE.12.dna.toplevel.fa -T SelectVariants -V $OUTPUT/$ID.raw_variants.vcf -o $OUTPUT/$ID.raw_snps.vcf -selectType SNP

# Copy file to vcf_out folder
cp $OUTPUT/$ID.raw_snps.vcf /work/tsewell/Aspergillus/Output/vcf_bulk
