#!/bin/bash
#genome prep
#sed 's/N//g' ebola_zaire.fasta | grep -v '^$\|^>' | tr -d '\n' | tr [a-z] [A-Z] > ez.txt
#echo -e '\n' >> ez.txt

yrs=$1

Rscript mutate.R "$yrs"
sed -i -e 's/ //g;s/^/>\n/g' mutant_reads.fa

bowtie2 -f -x EZ -U mutant_reads.fa -S ez_mut.sam --rg-id A --rg SM:EZ --rg PL:Illumina --rg LB:libA
