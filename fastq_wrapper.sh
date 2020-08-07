#!/bin/bash

#PBS -lselect=1:ncpus=1:mem=4gb
#PBS -lwalltime=2:00:00

module load fastqc/0.11.5
module load java

for dir in */; do
	cd -- "$dir"
	FQ1=*_1.fastq.gz
	FQ2=*_2.fastq.gz
	/apps/fastqc/0.11.5/fastqc $FQ1 $FQ2
	cd ..
done

#fastqc ${FQ1} ${FQ2} 


