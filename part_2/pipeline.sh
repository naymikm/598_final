#!/bin/bash

usage="\nUsage: bash pipeline.sh [options]\n
\t-f Samples unpaired fastq file
\t-g Path to the GATK jar file\n"

while getopts 'ha:b:c:d:g:' flag;
do
 case "${flag}" in
  a) fq="${OPTARG}" ;;
  g) gatk="${OPTARG}" ;;
  h) echo -e "$usage"; exit 1;;
  *)
     echo "Unrecognized option"
     echo -e "$usage"
     exit 1;;
 esac
done

if [[ -z "$fq" ]] || [[ -z "$gatk" ]]; then
 echo -e "\nError: Missing options"
 echo -e "$usage"
 exit 1
fi


bowtie2 -x ./seq_files/ref -U "$fq" -S a_temp_.sam \
--rg-id A --rg SM:sampleA --rg PL:Illumina --rg LB:libA

samtools view a_temp_.sam -bS -o data_temp_.bam

picard-tools MarkDuplicates INPUT=data_temp_.bam OUTPUT=dedup_temp_.bam METRICS_FILE=metrics_temp_.txt

picard-tools BuildBamIndex INPUT=dedup_temp_.bam

java -jar "$gatk" -T RealignerTargetCreator -R ./seq_files/reference.fasta -I dedup_temp_.bam \
-o rtc_temp_.intervals

java -jar "$gatk" -T IndelRealigner -R ./seq_files/reference.fasta -I dedup_temp_.bam \
-targetIntervals rtc_temp_.intervals -o realigned_temp_.bam

java -jar "$gatk" -T UnifiedGenotyper -I realigned_temp_.bam -R ./seq_files/reference.fasta \
-stand_call_conf 50 -stand_emit_conf 50 -ploidy 2 -glm BOTH -o first_temp_.vcf

java -jar "$gatk" -T BaseRecalibrator -I realigned_temp_.bam -R ./seq_files/reference.fasta \
--knownSites first_temp_.vcf -o recal_temp_.table

java -jar "$gatk" -T PrintReads -I realigned_temp_.bam -R ./seq_files/reference.fasta \
-BQSR recal_temp_.table -EOQ -o FINAL_recal.bam

java -jar "$gatk" -T UnifiedGenotyper -I FINAL_recal.bam -R ./seq_files/reference.fasta \
-ploidy 2 -glm BOTH -o FINAL_variant_calls.vcf

#rm *_temp_*
