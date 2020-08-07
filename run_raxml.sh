#!/bin/sh 
module load raxml/8.2.9
module load mpi/mpt-2.14
ID=${PBS_JOBID%%.ax4-login}

fasta="/work/tsewell/PopGen/Rhys/input/EVCA-positions-from-v-Name_tab_Type_all_c_gattii4-without-VGV.tab-m-4-s-2-i-n.fasta.phylip"
outdir="/work/tsewell/PopGen/Rhys/output"
prefix="RAXML-w-GTRCAT"

if [[ ! -d "${outdir}" ]]; then
	mkdir -p ${outdir}
fi

dplace raxmlHPC-PTHREADS-AVX -T 600 -w "${outdir}" -x 12345 -m GTRCAT -n "${prefix}.${ID}" -f a -s "${fasta}" -p 12345 -N 1000 2>${outdir}/${prefix}.${ID}.err 1>${outdir}/${prefix}.${ID}.out
#  # -np 140 raxmlHPC-MPI-AVX -w "${work_dir}" -T 140 -m GTRCAT -n "${name}" -f a -b 12345 -s "${fasta}" -p 12345 -N 1000
# raxmlHPC-PTHREADS-AVX -T 24 -p 12345 -m GTRCAT -w "${outdir}" -z "RAxML_bootstrap.${prefix}.${ID}" -I autoMRE -n "${prefix}.${ID}.convergence"

