#!/bin/bash

#PBS -N regenie1
#PBS -j oe
#PBS -o log
#PBS -l walltime=23:0:0
#PBS -l nodes=1:ppn=4
#PBS -l vmem=64gb
#PBS -W umask=022

eye_dir="/data/neuroretinal/ukb_master/genetics"
out_dir="/scratch/gen1/cb334/eyes_gwas"
pheno="mtcl"

module load regenie
regenie \
  --step 1 \
  --bed ${eye_dir}/ukb_cal_allchr_v2 \
  --extract ${eye_dir}/ukb_cal_allchr_eur_qc.snplist \
  --keep ${eye_dir}/ukb_cal_allchr_eur_qc.id \
  --phenoFile ${eye_dir}/mtcl_covar.txt \
  --phenoCol ${pheno} \
  --covarFile ${eye_dir}/mtcl_covar.txt \
  --covarColList age,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,PC11,PC12,PC13,PC14,PC15,BiLEVE.array,sex \
  --qt \
  --bsize 1000 \
  --loocv \
  --threads 4 \
  --gz \
  --out ${out_dir}/${pheno}.regenie.step1 
