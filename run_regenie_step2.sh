#!/bin/bash

#PBS -N regenie2
#PBS -j oe
#PBS -o log
#PBS -l walltime=72:0:0
#PBS -l nodes=1:ppn=4
#PBS -l vmem=64gb
#PBS -W umask=022


chr=$PBS_ARRAYID
eye_dir="/data/neuroretinal/ukb_master/genetics"
out_dir="/scratch/gen1/cb334/eyes_gwas"
pheno="mtcl"

module load regenie
regenie \
  --step 2 \
  --bgen /data/ukb/imputed_v3/ukb_imp_chr${chr}_v3.bgen \
  --ref-first \
  --sample ${eye_dir}/fam/ukb22828_c1_b0_v3_s487207.sample \
  --keep ${eye_dir}/ukb_cal_allchr_eur_qc.id \
  --phenoFile ${eye_dir}/mtcl_covar.txt \
  --phenoCol ${pheno} \
  --covarFile ${eye_dir}/mtcl_covar.txt \
  --covarColList age,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,PC11,PC12,PC13,PC14,PC15,BiLEVE.array,sex \
  --qt \
  --gz \
  --threads 4 \
  --minMAC 10 \
  --minINFO 0.3 \
  --firth --approx \
  --pred ${out_dir}/${pheno}.regenie.step1_pred.list \
  --bsize 1000 \
  --out ${out_dir}/${pheno}.${chr}.regenie.step2


