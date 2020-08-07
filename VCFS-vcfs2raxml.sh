#!/bin/bash
#PBS -lselect=18:ncpus=24:mem=64gb:mpiprocs=1:ompthreads=24
#PBS -lwalltime=48:00:00
module load bcftools/1.3.1
module load htslib
#module load R/3.3.0
module load anaconda3/personal
module load mpi
module load raxml/8.2.9



#  Output file prefix
outfile=${outdir}/${prefix}

if true; then
#  Select individuals and subset VCF to segregating sites
bcftools view -S ${samples} ${invcf} | perl /rds/general/user/tsewell/projects/fisher-bd-analysis/live/VCF-print_segregating_sites.pl - | bgzip -c > ${outfile}.vcf.gz

#  Create  a TSV file of IUPAC codes at each position for each sample
bcftools query -f '%CHROM\t%POS[\t%IUPACGT]\n' ${outfile}.vcf.gz | sed 's/\.\/\./\./g' | bgzip -c > ${outfile}.tsv.gz

#  Get the names from VCF file to use in Rscript
bcftools query -l ${outfile}.vcf.gz > ${outfile}.names

#  Create fasta file from TSV file and names file
Rscript /rds/general/user/tsewell/projects/fisher-bd-analysis/live/tsv2fasta.R ${outfile}.tsv.gz ${outfile}.names ${outfile}.fasta
fi

#  Label individual runs of trees
treeid=${PBS_JOBID%%.ax4-login}.${HOSTNAME}

echo "Running raxml"
#  Run raxml for 1000 bootstrap replicates
#  mpiexec must always be used on IC cluster- nevef mpirun etc and no flags. e.g. -n.
#  resources determined from PBS args
mpiexec raxmlHPC-HYBRID-SSE3 -T 24 -w ${outdir} -x 12345 -m GTRCAT -n ${prefix}.raxml.${treeid} -f a -s ${outdir}/${prefix}.fasta -p 12345 -N 1000 2>${outfile}.raxml.${treeid}.err 1>${outfile}.raxml.${treeid}.out

echo "Checking raxml convergence"
#  Check how quickly it converged
#raxmlHPC-PTHREADS -T 16 -p 12345 -m GTRCAT -w ${outdir} -z ${outdir}/RAxML_bootstrap.${prefix}.raxml.${treeid} -I autoMRE -n ${prefix}.raxml.${treeid}.convergence
