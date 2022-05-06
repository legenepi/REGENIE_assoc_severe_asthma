#!/bin/bash

#PBS -N regenie1
#PBS -j oe
#PBS -o log
#PBS -l walltime=23:0:0
#PBS -l nodes=1:ppn=4
#PBS -l vmem=64gb
#PBS -W umask=022

eye_dir="/data/neuroretinal/ukb_master/genetics"
PATH_DATA="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/data"
OUT_DIR="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
pheno="pheno_all_age"

module load regenie
regenie \
  --step 1 \
  --bed ${PATH_DATA}/ukb_allchr_v3 \
  --extract ${PATH_DATA}/ukb_cal_allchr_eur_qc.snplist \
  --keep ${PATH_DATA}/ukb_cal_allchr_eur_qc.id \
  --phenoFile ${PATH_DATA}/demo_EUR_pheno_cov.txt \
  --phenoCol ${pheno} \
  --covarFile ${PATH_DATA}/demo_EUR_pheno_cov.txt \
  --covarColList age_at_recruitment,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,sex,genetic_sex \
  --qt \
  --bsize 1000 \
  --loocv \
  --threads 4 \
  --gz \
  --out ${OUT_DIR}/${pheno}.regenie.step1
