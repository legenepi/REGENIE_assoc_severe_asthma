#PBS -j oe
#PBS -o log
#PBS -l walltime=30:0:0
#PBS -l nodes=1:ppn=4
#PBS -l vmem=100gb
#PBS -W umask=022

chr=3
PATH_DATA="/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/"
OUT_DIR="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
sample_DIR="/data/gen1/UKBiobank_500K/severe_asthma/data"
scratch_DIR="/scratch/gen1/nnp5/REGENIE_assoc/tmp_data"
pheno="broad_pheno_1_5_ratio"

#run as: qsub  src/broad_phenotype/REGENIE_rs778801698_BMIcovariate.sh

cd src/

#create covariate file with BMI:

module load regenie

regenie \
  --step 1 \
  --bed ${scratch_DIR}/ukb_cal_allchr_v2 \
  --extract ${scratch_DIR}/ukb_cal_allchr_eur_qc.snplist \
  --keep ${scratch_DIR}/ukb_cal_allchr_eur_qc.id \
  --phenoFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma.txt \
  --phenoCol ${pheno} \
  --covarFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma.txt \
  --covarColList age_at_recruitment,age2,BMI,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,genetic_sex \
  --bt \
  --bsize 1000 \
  --loocv \
  --threads 4 \
  --gz \
  --out ${OUT_DIR}/rs778801698_BMIcovariate_${pheno}.regenie.step1


regenie \
  --step 2 \
  --bgen /data/ukb/imputed_v3/ukb_imp_chr${chr}_v3.bgen \
  --ref-first \
  --sample ${sample_DIR}/ukbiobank_app56607_for_regenie.sample \
  --keep ${scratch_DIR}/ukb_cal_allchr_eur_qc.id \
  --phenoFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma.txt \
  --phenoCol ${pheno} \
  --covarFile ${PATH_DATA}/demo_EUR_pheno_cov_broadasthma.txt \
  --covarColList age_at_recruitment,age2,BMI,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,genetic_sex \
  --bt \
  --gz \
  --threads 4 \
  --minMAC 10 \
  --minINFO 0.3 \
  --firth --approx --pThresh 0.01 \
  --pred ${OUT_DIR}/${pheno}.regenie.step1_pred.list \
  --bsize 1000 \
  --out ${OUT_DIR}/rs778801698_BMIcovariate_${pheno}.${chr}.regenie.step2


Rscript /home/n/nnp5/PhD/PhD_project/Post_GWAS/src/create_input_munge_summary_stats.R \
    /home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output/rs778801698_BMIcovariate_broad_pheno_1_5_ratio.3.regenie.step2_broad_pheno_1_5_ratio.regenie.gz \
    rs778801698_BMIcovariate_broad_pheno_1_5_ratio

awk -F "\t" '$9 <= 0.00000005 {print $0}' \
    /home/n/nnp5/PhD/PhD_project/Post_GWAS/output/maf001_rs778801698_BMIcovariate_broad_pheno_1_5_ratio_betase_input_mungestat