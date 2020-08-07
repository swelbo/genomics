#!/bin/sh

#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=100:mem=128gb
#qsub -lwalltime=72:00:00 -lmem=128gb -lncpus=100 -- sewell_raxml_bootstrap.sh

module load raxml/8.2.9
module load mpi/mpt-2.14

PATH=$PATH:/apps/raxml/8.2.9/standard-RAxML

dplace /apps/raxml/8.2.9/standard-RAxML/raxmlHPC-PTHREADS-AVX -T 10 -s /work/tsewell/PopGen/Rhys/input/EVCA-positions-from-v-Name_tab_Type_all_c_gattii4.tab-m-4-s-2-i-n.fasta.phylip -m BINGAMMA -p 12345 -f a -x 12345 -N 1000 -n all_DAR -w /work/tsewell/PopGen/Rhys/output/

