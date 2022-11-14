#!/bin/bash

#PBS -N regenie12_broadpheno_male
#PBS -j oe
#PBS -o log_step2_sexstratified
#PBS -l walltime=11:0:0
#PBS -l nodes=1:ppn=4
#PBS -l vmem=50gb
#PBS -W umask=022

chr=$PBS_ARRAYID
PATH_DATA="/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/"
sample_DIR="/data/gen1/UKBiobank_500K/severe_asthma/data"
OUT_DIR="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
scratch_DIR="/scratch/gen1/nnp5/REGENIE_assoc/tmp_data"
pheno="broad_pheno_male"

#to change in "broad_pheno_male" if for male
#to change in "broad_pheno_female" if for female

# to run: qsub -t 1-22 src/broad_phenotype/sexstratified_run_regenie_step2.sh


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
