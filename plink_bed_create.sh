#!/bin/bash

module load plink
module load admixture

# adjust chr names 
awk '{gsub(/^Supercontig_/,""); print}' your.vcf > no_chr.vcf

# generate ped 
plink --vcf ../pria/merged/000_bd.pria.2019.global.panel.snps.only.integar.vcf --allow-extra-chr --freq --recode --maf 0.05 --geno 0.1 --chr-set 69 no-xy no-mt --out priaSNPs 

# generate bed
plink --file priaSNPs --allow-extra-chr --chr-set 69 no-xy no-mt

# run admixture 
admixture32 plink.bed 3

# Summary: 
#Converged in 13 iterations (66.714 sec)
#Loglikelihood: -4770700.605858
#Fst divergences between estimated populations: 
#	Pop0	Pop1	
#Pop0	
#Pop1	0.640	
#Pop2	0.437	0.516	
#Writing output files