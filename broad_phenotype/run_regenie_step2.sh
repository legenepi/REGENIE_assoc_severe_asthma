#!/bin/bash

#PBS -N regenie2
#PBS -j oe
#PBS -o log_regenie_step2
#PBS -l walltime=13:0:0
#PBS -l nodes=1:ppn=4
#PBS -l vmem=64gb
#PBS -W umask=022

chr=$PBS_ARRAYID
PATH_DATA="/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/"
OUT_DIR="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
sample_DIR="/data/gen1/UKBiobank_500K/severe_asthma/data"
scratch_DIR="/scratch/gen1/nnp5/REGENIE_assoc/tmp_data"
pheno="broad_pheno_1_5_ratio"

#run as: qsub -t 1-22 src/broad_phenotype/run_regenie_step2.sh

cd src/

#if additive (default, so no need to explicit it):
module load regenie
regenie \
  --step 2 \
  --bgen /data/ukb/imputed_v3/ukb_imp_chr${chr}_v3.bgen \
  --ref-first \
  --sample ${sample_DIR}/ukbiobank_app56607_for_regenie.sample \
  --keep ${scratch_DIR}/ukb_cal_allchr_eur_qc.id \
  --phenoFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma.txt \
  --phenoCol ${pheno} \
  --covarFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma.txt \
  --covarColList age_at_recruitment,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,genetic_sex \
  --bt \
  --gz \
  --threads 4 \
  --minMAC 10 \
  --minINFO 0.3 \
  --firth --approx --pThresh 0.01 \
  --pred ${OUT_DIR}/${pheno}.regenie.step1_pred.list \
  --bsize 1000 \
  --out ${OUT_DIR}/${pheno}.${chr}.regenie.step2


#if recessive or dominant:
#test_type="additive" #additive, this variable is NULL (default) or dominant
#module load regenie
#regenie \
#  --step 2 \
#  --bgen /data/ukb/imputed_v3/ukb_imp_chr${chr}_v3.bgen \
#  --ref-first \
#  --sample ${sample_DIR}/ukbiobank_app56607_for_regenie.sample \
#  --keep ${scratch_DIR}/ukb_cal_allchr_eur_qc.id \
#  --phenoFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma.txt \
#  --phenoCol ${pheno} \
#  --covarFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma.txt \
#  --covarColList age_at_recruitment,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,genetic_sex \
#  --bt \
#  --gz \
#  --threads 4 \
#  --minMAC 10 \
#  --minINFO 0.3 \
#  --firth --approx --pThresh 0.01 \
#  --pred ${OUT_DIR}/${pheno}.${test_type}regenie.step1_pred.list \
#  --bsize 1000 \
#  --test ${test_type} \
#  --out ${OUT_DIR}/${pheno}.${chr}.${test_type}regenie.step2