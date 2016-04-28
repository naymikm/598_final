#!/bin/bash
#genome prep
#sed 's/N//g' ebola_zaire.fasta | grep -v '^$\|^>' | tr -d '\n' | tr [a-z] [A-Z] > ez.txt
#echo -e '\n' >> ez.txt

#echo -e "WARNING! If running more than 1 simulation, you must delete the file mutant_reads.fa between runs\n"
yrs=$1

Rscript mutate.R "$yrs"
sed -i -e s/CHROM/#CHROM/ ez.vcf
java -jar /home/marcus/bio/TOOLS/snpEff/snpEff.jar ebola_zaire ez.vcf > ez.ann.vcf
echo -e "\nSee ez.ann.vcf for the annotated vcf file!\n"
echo -e "Opening HTML Summary..."
xdg-open snpEff_summary.html
