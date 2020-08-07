#!/bin/bash
#PBS -lselect=1:ncpus=16:mem=64gb
#PBS -lwalltime=48:00:00

# MEDUSA! 

module load java
module load anaconda3/personal
module load mummer

# move to medusa 
cd /rds/general/user/tsewell/home/medusa/

# command
java -jar /rds/general/user/tsewell/home/medusa/medusa.jar -f /rds/general/user/tsewell/home/medusa/bd/ -i /rds/general/user/tsewell/projects/fisher-bd-results/live/pacbio/spades/IA042/contigs.fasta -v