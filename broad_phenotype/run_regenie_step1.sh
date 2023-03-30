#!/bin/bash

#PBS -N regenie1
#PBS -j oe
#PBS -o log
#PBS -l walltime=15:0:0
#PBS -l nodes=1:ppn=4
#PBS -l vmem=50gb
#PBS -W umask=022

PATH_DATA="/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/"
OUT_DIR="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
scratch_dir="/scratch/gen1/nnp5/REGENIE_assoc/tmp_data"
pheno="broad_pheno_1_5_ratio" #broad_pheno_1_5_ratio or broad_pheno_1_5_ratio
test_type="recessive" #additive, this variable is NULL (default) or dominant

module load regenie
regenie \
  --step 1 \
  --bed ${scratch_dir}/ukb_cal_allchr_v2 \
  --extract ${scratch_dir}/ukb_cal_allchr_eur_qc.snplist \
  --keep ${scratch_dir}/ukb_cal_allchr_eur_qc.id \
  --phenoFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma.txt \
  --phenoCol ${pheno} \
  --covarFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma.txt \
  --covarColList age_at_recruitment,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,genetic_sex \
  --bt \
  --bsize 1000 \
  --loocv \
  --threads 4 \
  --gz \
  --test ${test_type} \
  --out ${OUT_DIR}/${pheno}.${test_type}regenie.step1
