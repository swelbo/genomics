import vcf

def compare_vcfs(vcf1, vcf2):
    vcf1_reader = vcf.Reader(open(vcf1, 'r'))
    vcf2_reader = vcf.Reader(open(vcf2, 'r'))

    # Create sets to store the variants in each VCF
    vcf1_variants = set()
    vcf2_variants = set()

    # Iterate through the records in each VCF
    for record in vcf1_reader:
        vcf1_variants.add((record.CHROM, record.POS, record.REF, record.ALT))
    for record in vcf2_reader:
        vcf2_variants.add((record.CHROM, record.POS, record.REF, record.ALT))

    # Print the unique variants in each VCF
    print("Unique variants in {}:".format(vcf1))
    for variant in vcf1_variants - vcf2_variants:
        print(variant)
    print("Unique variants in {}:".format(vcf2))
    for variant in vcf2_variants - vcf1_variants:
        print(variant)

# Example usage
compare_vcfs("vcf1.vcf", "vcf2.vcf")


import os

def compare_all_vcfs(directory):
    # Get a list of all VCF files in the directory
    vcf_files = [f for f in os.listdir(directory) if f.endswith('.vcf')]

    # Loop over all pairs of VCF files
    for i in range(len(vcf_files)):
        for j in range(i+1, len(vcf_files)):
            vcf1 = os.path.join(directory, vcf_files[i])
            vcf2 = os.path.join(directory, vcf_files[j])
            compare_vcfs(vcf1, vcf2)

# Example usage
compare_all_vcfs("/path/to/vcfs")


'''
This script uses the PyVCF library to read the VCF files, so you'll need to have it installed. The script defines a function compare_vcfs() that takes the filenames of the two VCFs as arguments. The function creates two sets, vcf1_variants and vcf2_variants, to store the variants in each VCF. It then iterates through the records in each VCF, adding the variant information (chromosome, position, reference allele, and alternate allele) to the appropriate set. Finally, it prints the unique variants in each VCF by using the set difference operator -.
You can change the function to return the unique variants in each file or store it in a variable for further usage.
Please note that this script only compares 4 fields of each variant. You can add more fields to the tuple to compare more fields.

import os

def compare_all_vcfs(directory):
    # Get a list of all VCF files in the directory
    vcf_files = [f for f in os.listdir(directory) if f.endswith('.vcf')]

    # Loop over all pairs of VCF files
    for i in range(len(vcf_files)):
        for j in range(i+1, len(vcf_files)):
            vcf1 = os.path.join(directory, vcf_files[i])
            vcf2 = os.path.join(directory, vcf_files[j])
            compare_vcfs(vcf1, vcf2)

# Example usage
compare_all_vcfs("/path/to/vcfs")

import glob
def compare_all_vcfs(directory):
    vcf_files = glob.glob(directory+"/*.vcf")
    for i in range(len(vcf_files)):
        for j in range(i+1, len(vcf_files)):
            compare_vcfs(vcf_files[i], vcf_files[j])

'''

