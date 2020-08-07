#!/bin/bash

#PBS -lselect=1:ncpus=8:mem=8gb
#PBS -lwalltime=24:00:00
#  Reset BASH timer
SECONDS=0

module load bwa/0.7.8
module load samtools/1.3.1
threads=8

#  Input to this file is a 3 column text file. Example columns below:
#  Column 1 is sample name, 2 is directory with input BAMs to be merged and column 3 is output bam file

#  -----------------------------------------------
#  Sample   INBAM                           OUTBAM
#  JEL423   /med-bio/bams/trimmed/JEL423    /med-bio/bams/trimmed/JEL423/JEL423_merged.bam
#  PA01   /med-bio/bams/trimmed/PA01        /med-bio/bams/trimmed/PA01/PA01_merged.bam
#  -----------------------------------------------

#  Which line are we processing
i=$PBS_ARRAY_INDEX

#  Input files array and output file name
infls=( $( cat ${argsfile} | awk -v idx="$i" ' NR == idx { print $2 }' | tr ',' '\n' ) )
outbam=$( cat ${argsfile} | awk -v idx="$i" ' NR == idx { print $3 }' )

#  Do the merge
samtools merge -@ ${threads} ${outbam} ${infls[@]}
samtools index ${outbam}
samtools flagstat ${outbam} | tr -s ' + ' $'\t' | cut -f-2 | awk '{if (NR == 1) {print $1"\n"$2} else if (NR != 1) print $1}' | paste -sd$'\t' <( echo $sample ) - | tr $'\n' $'\t' >> ${HOME}/raw_bam_flagstats.txt

#  Remove the input files as long as BAM merging was succesful
if [[ -s ${outbam} ]]; then
  rm ${infls[@]}
fi

#  Run time of the script (not CPU time etc)
echo -e "\nElapsed: $(($SECONDS / 3600)) hrs $((($SECONDS / 60) % 60)) min $(($SECONDS % 60)) sec"
