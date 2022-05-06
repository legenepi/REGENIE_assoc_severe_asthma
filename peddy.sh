#!/bin/bash

#PBS -N peddy
#PBS -j oe
#PBS -o peddy_og
#PBS -l walltime=4:0:0
#PBS -l nodes=1:ppn=4
#PBS -l vmem=64gb
#PBS -W umask=022

#run this job: qsub -t 1-22 ./peddy.sh

geno_dir="/data/ukb/genotyped"
data_dir="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/data"

#interactively:
#cp /rfs/TobinGroup/data/UKBiobank/application_56607/ukb56607_cal_chr1_v2_s488239.fam \
#    ${data_dir}/ukb56607_cal_chr1_v2_s488239.fam

#Create ped and vcf from plink files from genotyped data
module load plink

plink --bed ${geno_dir}/ukb_cal_chr${i}_v2.bed \
  --bim ${geno_dir}/ukb_cal_chr${i}_v2.bim \
  --fam ${data_dir}/ukb56607_cal_chr1_v2_s488239.fam \
  --recode \
  --out ${data_dir}/text_ukb_cal_chr${i}_v2

#plink --file ../data/text_ukb_cal_chr21_v2 --merge ../data/text_ukb_cal_chr20_v2 --recode --out ../data/merge_file
