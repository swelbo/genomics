#!/bin/sh

#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=16:mem=32gb

module load raxml/8.2.9
module load mpi/mpt-2.14

PATH=$PATH:/apps/raxml/8.2.9/standard-RAxML

dplace /apps/raxml/8.2.9/standard-RAxML/raxmlHPC-PTHREADS-AVX -T 10 -s /work/jlrhodes/Cryptococcus/output/Phylogeny/all_DAR.phy -m BINGAMMA -p 12345 -f a -x 12345 -N 500 -n all_DAR -w /work/jlrhodes/Cryptococcus/output/Phylogeny/

