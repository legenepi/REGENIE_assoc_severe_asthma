#!/bin/bash

#PBS -N regenie2
#PBS -j oe
#PBS -o log
#PBS -l walltime=72:0:0
#PBS -l nodes=1:ppn=4
#PBS -l vmem=64gb
#PBS -W umask=022

chr=$PBS_ARRAYID
PATH_DATA="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/data"
OUT_DIR="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
pheno="pheno_all_age"

module load regenie
regenie \
  --step 2 \
  --bgen /data/ukb/imputed_v3/ukb_imp_chr${chr}_v3.bgen \
  --ref-first \
  #--sample  \
  --keep ${PATH_DATA}/ukb_cal_allchr_eur_qc.id \
  --phenoFile $${PATH_DATA}/demo_EUR_pheno_cov.txt \
  --phenoCol ${pheno} \
  --covarFile ${PATH_DATA}/demo_EUR_pheno_cov.txt \
  --covarColList age_at_recruitment,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,sex,genetic_sex \
  --qt \
  --gz \
  --threads 4 \
  --minMAC 10 \
  --minINFO 0.3 \
  --firth --approx \
  --pred ${OUT_DIR}/${pheno}.regenie.step1_pred.list \
  --bsize 1000 \
  --out ${OUT_DIR}/${pheno}.${chr}.regenie.step2


