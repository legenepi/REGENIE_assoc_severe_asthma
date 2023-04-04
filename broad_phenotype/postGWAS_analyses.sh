#!/bin/bash

#PBS -N post_gwas_asthma_broadpheno
#PBS -j oe
#PBS -o post_gwas_asthma_broadpheno
#PBS -l walltime=3:0:0
#PBS -l vmem=50gb
#PBS -l nodes=1:ppn=1
#PBS -d .
#PBS -W umask=022


#Set variables:
PATH_OUT="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
PHENO="broad_pheno_1_5_ratio"

#PHENO to change into:
#"broad_pheno_1_5_ratio"
#"broad_pheno_female"
#"broad_pheno_male"
#"broad_pheno_adultonset"
#"broad_pheno_childhoodonset"
#"broad_pheno_1_5_ratio"
test_type="recessive" #additive: NULL. use ONLY  this variable only with dominant or recessive test
test_type_underscore="recessive_" #additive: NULL. use ONLY  this variable only with dominant or recessive test

#N of individuals, to change:
tot_n=46086
#tot_n for broad pheno (additive recessive and dominant): 46086
#tot_n for broad pheno female: 29646
#tot_n for broad pheno male: 16440
#tot_n for broad pheno adultonset: 42919
#tot_n for broad pheno childhoodonset: 39944

#mkdir ${PATH_OUT}/allchr
GWAS="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output/allchr"


#merge all assoc file:
#zcat ${PATH_OUT}/${PHENO}.1.${test_type}regenie.step2_${PHENO}.regenie.gz | tail -n +2 | \
#     awk -F " " '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13}' \
#    > ${GWAS}/${PHENO}_${test_type}allchr.assoc.txt

#for i in {2..22}
#    do zcat ${PATH_OUT}/${PHENO}.${i}.${test_type}regenie.step2_${PHENO}.regenie.gz | \
#    tail -n +2 | awk -F " " '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13}' \
#    >> ${GWAS}/${PHENO}_${test_type}allchr.assoc.txt
#done

#gzip ${GWAS}/${PHENO}_${test_type}allchr.assoc.txt

#create input ldsc file both for all vars and maf >= 0.01.
#module unload R/4.2.1
#module load R/4.1.0
#chmod o+x src/create_input_munge_summary_stats.R
#dos2unix src/create_input_munge_summary_stats.R
#Rscript src/create_input_munge_summary_stats.R \
#    ${GWAS}/${PHENO}_${test_type}allchr.assoc.txt.gz \
#    ${PHENO}_${test_type}

#LDSC interactively.
#The results are the same for set with all vars and fitlered maf 0.01., because LDSC uses only vars > 0.01. So run
#on the filtered set
cd /home/n/nnp5/software/ldsc
conda activate ldsc

PHENO="maf001_broad_pheno_1_5_ratio"
#"maf001_broad_pheno_1_5_ratio" for additive, recessive, dominant models
#"maf001_broad_pheno_female"
#"maf001_broad_pheno_male"
#"maf001_broad_pheno_adultonset"
#"maf001_broad_pheno_childhoodonset"

#awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9}' ${PATH_OUT}/${PHENO}_${test_type_underscore}betase_input_mungestat \
#    > ${PATH_OUT}/${PHENO}_${test_type_underscore}betase_input_mungestat_clean

#interactively:
#/home/n/nnp5/software/ldsc/munge_sumstats.py \
#--sumstats ${PATH_OUT}/${PHENO}_${test_type_underscore}betase_input_mungestat_clean \
#--N ${tot_n}   \
#--out ${PATH_OUT}/${PHENO}_${test_type_underscore}allchr_step2_regenie \
#--merge-alleles /data/gen1/UKBiobank/Smoking/Meta_Analysis_AWI_UGR_UKBAFR/files/w_hm3.snplist \
#--chunksize 500000

#/home/n/nnp5/software/ldsc/ldsc.py \
#--h2 ${PATH_OUT}/${PHENO}_${test_type_underscore}allchr_step2_regenie.sumstats.gz \
#--ref-ld-chr /data/gen1/reference/ldsc/eur_w_ld_chr/ \
#--w-ld-chr /data/gen1/reference/ldsc/eur_w_ld_chr/ \
#--out ${PATH_OUT}/${PHENO}_${test_type_underscore}allchr_step2_regenie_h2

#conda deactivate
#cd /home/n/nnp5/PhD/PhD_project/REGENIE_assoc/

#Plots:
ldsc_intercept=1.00
#broad pheno:'1.02'
#broad pheno female:'1.02'
#broad pheno adultonset:'1.00'
#broad pheno male:'1.04'
#broad pheno childhoodonset:'1.02'
#broad pheno dominant:'1.01'
#broad pheno recessive:'1.00'

#run Manhattan, qqplot, lambda for vars with maf >= 0.01:
module unload R/4.2.1
module load R/4.1.0
chmod o+x src/REGENIE_plots.R
dos2unix src/REGENIE_plots.R
Rscript src/REGENIE_plots.R \
    ${PATH_OUT}/${PHENO}_${test_type_underscore}betase_input_mungestat \
    ${PHENO}_${test_type} \
    ${ldsc_intercept}

#extract only genome-wide significant variants:
#awk -F "\t" '$9 <= 0.00000005 {print $0}' ${PATH_OUT}/${PHENO}_${test_type_underscore}betase_input_mungestat \
#    > ${PATH_OUT}/${PHENO}_${test_type_underscore}genomewide_signif

#Sentinel selection:
#module unload R/4.2.1
#module load R/4.1.0
#chmod o+x src/sentinel_selection.R
#dos2unix src/sentinel_selection.R
#Rscript src/sentinel_selection.R \
#    ${PATH_OUT}/${PHENO}_${test_type_underscore}betase_input_mungestat \
#    ${PHENO} \
#    500000 \
#    0.00000005 \
#    ${test_type}

#create OddsRatio and direction of effect using Create_oddsratio.R
#Rscript src/broad_phenotype/Create_oddsratio.R ${PATH_OUT}/${PHENO}${test_type}_sentinel_variants.txt ${PATH_OUT}/${PHENO}_${test_type_underscore}sentinel_variants_OR.txt

