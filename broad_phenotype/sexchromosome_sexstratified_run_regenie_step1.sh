#!/bin/bash

#PBS -N sexchrom_regenie1_broadpheno_male
#PBS -j oe
#PBS -o log_sexchrom_regenie_step1
#PBS -l walltime=11:0:0
#PBS -l nodes=1:ppn=4
#PBS -l vmem=50gb
#PBS -W umask=022

PATH_DATA="/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/"
OUT_DIR="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
scratch_dir="/scratch/gen1/nnp5/REGENIE_assoc/tmp_data"
pheno="broad_pheno_female"
#to change in "broad_pheno_male_sexchr" if for male
#to change in "broad_pheno_female_sexchr" if for female

# to run: qsub src/broad_phenotype/sexchromosome_sexstratified_run_regenie_step1.sh

module load regenie
regenie \
  --step 1 \
  --bed ${scratch_dir}/ukb_cal_allchr_v2_sexchr \
  --extract ${scratch_dir}/ukb_cal_allchr_eur_qc_sexchr.snplist \
  --keep ${scratch_dir}/ukb_cal_allchr_eur_qc_sexchr.id \
  --phenoFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma_ageonset_sexstratified.txt \
  --phenoCol ${pheno} \
  --covarFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma_ageonset_sexstratified.txt \
  --covarColList age_at_recruitment,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
  --bt \
  --bsize 1000 \
  --loocv \
  --threads 4 \
  --gz \
  --out ${OUT_DIR}/${pheno}_sexchr.regenie.step1