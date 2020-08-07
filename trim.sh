#!/bin/bash

##PBS -l mem=8gb
##PBS -l walltime=10:00:00
##PBS -l ncpus=8

#PBS -lselect=1:ncpus=8:mem=8gb
#PBS -lwalltime=10:00:00

#  Input variables
#  1) An array of forward reads (${reads1[@]})
#  2) An array of reverse reads (${reads2[@]})
#  3) An output directory ($trimout)

i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
reads1=(${args1})
reads2=(${args2})

#  Load required modules on ax3
module load java/jdk-7u25
module load gatk/3.5
module load bwa/0.7.8
module load anaconda3/personal
#module load cutadapt/1.10
module load biopython/1.57

#  read1 [and read2] should be the absolute path to the read files
READS=("${reads1[$i]}" "${reads2[$i]}")

sample=$(basename $( dirname ${READS[1]} ) )

if [[ ! -d "${trimout}/${sample}" ]]; then
	mkdir "${trimout}/${sample}"
fi

#  Other variables passed to the script are
#  $ref:    location of the reference genome fasta
#  $out:    where you want the output bam to go
#  $trimout:  where you want trimmed reads to go


#  Adapter and quality trimming of read files
#--------------------------------------------------------------------------------#
#  See footnote at bottom for this adapter hack//
adapter="AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC"
if [[ "$sample" =~ "CLFT024_2" ]]; then
	adapter="GATCGGAAGAGCACACGTCTGAACTCCAGTCAC"
fi

#  Single end read trimming
if [ "${#READS[@]}" -eq 1 ]; then
	out=$( basename ${READS[0]} )
	echo "Performing single end trimming on $fls using adapter sequence $adapter on `date`"
	cutadapt \
	-f fastq \
	-a "$adapter" \
	--max-n 0.2 \
	--minimum-length 25 \
	--trim-n \
	-q 20,20 \
	-o "${trimout}/$sample/${out%%.*}.trimmed.SE.fq.gz" "${READS[0]}"
fi

#  Paired-end read trimming
if [ "${#READS[@]}" -eq 2 ]; then
	out1=$( basename ${READS[0]} )
	out2=$( basename ${READS[1]} )
	echo "Performing paired-end trimming on ${READS[0]} and ${READS[1]} on `date`"
	cutadapt \
	-f fastq \
	-a "$adapter" \
	-A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT \
	--max-n 0.2 \
	--minimum-length 25 \
	--trim-n \
	-q 20,20 \
	-o "${trimout}/$sample/${out1%%.*}.trimmed.R1.fq.gz" -p "${trimout}/$sample/${out2%%.*}.trimmed.R2.fq.gz" \
	"${READS[0]}" "${READS[1]}" 1>"${trimout}/$sample/${out2%%.*}report.txt"
fi

#  Check output file(s) before continuing...
fls=("${trimout}/${sample}/*.fq.gz")
for f in "${fls[@]}"
do
	if [[ ! -s "$f" ]]; then
		echo "Trimming of $f needs to be repeated!" >> $HOME/cutadapt.trimming.log
	fi
done
