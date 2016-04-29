#!/bin/bash

usage="\nUsage: bash pipeline.sh [options]\n
\t-f Samples unpaired fastq file
\t-g Path to the GATK jar file\n"

while getopts 'hg:f:' flag;
do
 case "${flag}" in
  f) fq="${OPTARG}" ;;
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

sample="${fq:10:3}"

echo "$sample"

#samtools 0.1.19
echo -e "\nRunning sequence alignment...\n"
bowtie2 -x ./seq_files/ref -U "$fq" -S a_temp_.sam \
--rg-id A --rg SM:sampleA --rg PL:Illumina --rg LB:libA

samtools view a_temp_.sam -bS -o data_temp_.bam

samtools sort data_temp_.bam sorted_temp_

picard-tools MarkDuplicates INPUT=sorted_temp_.bam OUTPUT=dedup_temp_.bam METRICS_FILE=metrics_temp_.txt

picard-tools BuildBamIndex INPUT=dedup_temp_.bam

java -Xmx3g -jar "$gatk" -T RealignerTargetCreator -R seq_files/reference.fasta -I dedup_temp_.bam \
-o rtc_temp_.intervals

java -Xmx3g -jar "$gatk" -T IndelRealigner -R seq_files/reference.fasta -I dedup_temp_.bam \
-targetIntervals rtc_temp_.intervals -o realigned_temp_.bam

java -Xmx3g -jar "$gatk" -T UnifiedGenotyper -I realigned_temp_.bam -R seq_files/reference.fasta \
-stand_call_conf 50 -stand_emit_conf 50 -ploidy 2 -glm BOTH -o first_temp_.vcf

java -Xmx3g -jar "$gatk" -T BaseRecalibrator -I realigned_temp_.bam -R seq_files/reference.fasta \
--knownSites first_temp_.vcf -o recal_temp_.table

java -Xmx3g -jar "$gatk" -T PrintReads -I realigned_temp_.bam -R seq_files/reference.fasta \
-BQSR recal_temp_.table -EOQ -o "$sample"_recal.bam

java -Xmx3g -jar "$gatk" -T UnifiedGenotyper -I "$sample"_recal.bam -R seq_files/reference.fasta \
-ploidy 2 -glm BOTH -o "$sample".vcf

rm *_temp_*
