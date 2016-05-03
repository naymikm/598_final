#!/bin/bash
#Add usage and refactor commands to use the args!!

while getopts 'hr:s:y:' flag;
do
 case "${flag}" in
  r) rscript="{OPTARG}";;
  s) snpeff="{OPTARG}";;
  y) years="{OPTARG}";;
  h) echo -e "$usage"; exit 1;;
  *)
     echo "Unrecognised option"
     echo -e "$usage"; exit 1;;
 esac
done

if [[ -z "$rscript" ]] || [[ -z "$snpeff" ]] ||[[ -z "$years" ]]; then 
 echo -e "\nError: Missing options"
 echo -e "$usage"
 exit 1
fi

yrs=$1
echo -e "Mutating..."
Rscript mutate.R "$yrs"
sed -i -e s/CHROM/#CHROM/ ez.vcf
echo -e "Annotating..."
java -jar /home/marcus/bio/TOOLS/snpEff/snpEff.jar ebola_zaire ez.vcf > ez.ann.vcf
echo -e "\nSee ez.ann.vcf for the annotated vcf file!\n"
echo -e "Opening HTML Summary..."
xdg-open snpEff_summary.html
