#!/bin/bash
#PBS -lselect=1:ncpus=16:mem=64gb
#PBS -lwalltime=72:00:00

# SPADES HYBRID ASSEMBLY!

module load anaconda3/personal 

# illumina reads
IA042_1=(/rds/general/user/tsewell/projects/fisher-bd-rawdata/live/bd/Fisher-Bd-RawData/FISHER_SEQ/IA042_Highly_passaged/*R1_001.fastq.gz) 

IA042_2=(/rds/general/user/tsewell/projects/fisher-bd-rawdata/live/bd/Fisher-Bd-RawData/FISHER_SEQ/IA042_Highly_passaged/*R2_001.fastq.gz)

spades.py --careful --pe1-1 $IA042_1 --pe1-2 $IA042_2 --pacbio /rds/general/user/tsewell/projects/fisher-bd-rawdata/live/pacbio/assembly/IA042_59/filtered_subreads.fasta -o /rds/general/user/tsewell/projects/fisher-bd-results/live/pacbio/hybridSPADES
