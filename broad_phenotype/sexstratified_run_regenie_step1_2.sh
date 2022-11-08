#!/bin/bash

#PBS -N regenie12_broadpheno_female
#PBS -j oe
#PBS -o log
#PBS -l walltime=10:0:0
#PBS -l nodes=1:ppn=4
#PBS -l vmem=50gb
#PBS -W umask=022

PATH_DATA="/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/"
OUT_DIR="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
scratch_dir="/scratch/gen1/nnp5/REGENIE_assoc/tmp_data"
pheno="broad_pheno_female" #to change in "broad_pheno_male" if for male

# to run: qsub -t 1-22 src/broad_phenotype/sexstratified_run_regenie_step1_2.sh

module load regenie
regenie \
  --step 1 \
  --bed ${scratch_dir}/ukb_cal_allchr_v2 \
  --extract ${scratch_dir}/ukb_cal_allchr_eur_qc.snplist \
  --keep ${scratch_dir}/ukb_cal_allchr_eur_qc.id \
  --phenoFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma_ageonset_sexstratified.txt \
  --phenoCol ${pheno} \
  --covarFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma_ageonset_sexstratified.txt \
  --covarColList age_at_recruitment,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
  --bt \
  --bsize 1000 \
  --loocv \
  --threads 4 \
  --gz \
  --out ${OUT_DIR}/${pheno}.regenie.step1


module load regenie
regenie \
  --step 2 \
  --bgen /data/ukb/imputed_v3/ukb_imp_chr${chr}_v3.bgen \
  --ref-first \
  --sample ${sample_DIR}/ukbiobank_app56607_for_regenie.sample \
  --keep ${scratch_DIR}/ukb_cal_allchr_eur_qc.id \
  --phenoFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma_ageonset_sexstratified.txt \
  --phenoCol ${pheno} \
  --covarFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma_ageonset_sexstratified.txt \
  --covarColList age_at_recruitment,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
  --bt \
  --gz \
  --threads 4 \
  --minMAC 10 \
  --minINFO 0.3 \
  --firth --approx --pThresh 0.01 \
  --pred ${OUT_DIR}/${pheno}.regenie.step1_pred.list \
  --bsize 1000 \
  --out ${OUT_DIR}/${pheno}.${chr}.regenie.step2
