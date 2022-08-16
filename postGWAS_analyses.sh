#!/bin/bash

#PBS -N post_gwas_asthma
#PBS -j oe
#PBS -o post_gwas_asthma
#PBS -l walltime=4:0:0
#PBS -l vmem=50gb
#PBS -l nodes=1:ppn=1
#PBS -d .
#PBS -W umask=022

PATH_OUT="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
PHENO="pheno_1_5_ratio"

#mkdir ${PATH_OUT}/allchr
GWAS="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output/allchr"

#merge all assoc file:
#zcat ${PATH_OUT}/${PHENO}.1.regenie.step2_pheno_1_5_ratio.regenie.gz | tail -n +2 \
#    > ${GWAS}/tmp_${PHENO}_allchr.assoc.txt

#for i in {2..22}
#    do zcat ${PATH_OUT}/${PHENO}.${i}.regenie.step2_pheno_1_5_ratio.regenie.gz | \
#    tail -n +2 \
#    >> ${GWAS}/tmp_${PHENO}_allchr.assoc.txt
#done

#awk -F " " '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14}' ${GWAS}/tmp_${PHENO}_allchr.assoc.txt \
#    > ${GWAS}/${PHENO}_allchr.assoc.txt
#gzip ${GWAS}/${PHENO}_allchr.assoc.txt

#create input ldsc file both for all vars and maf >= 0.01.
#module unload R/4.2.1
#module load R/4.1.0
#chmod o+x src/create_input_munge_summary_stats.R
#dos2unix src/create_input_munge_summary_stats.R
#Rscript src/create_input_munge_summary_stats.R \
#    ${GWAS}/${PHENO}_allchr.assoc.txt.gz \
#    ${PHENO}

#LDSC interactively.
#The results are the same for set with all vars and fitlered maf 0.01., because LDSC uses only vars > 0.01. So run
#on the filtered set
#cd /home/n/nnp5/software/ldsc

#conda activate ldsc

#with maf >= 001:
#PHENO="maf001_pheno_1_5_ratio"
#awk -F " " '{print $1, $2, $3, $4, $5, $6, $7, $8, $9}' \
#    ${PATH_OUT}/${PHENO}_betase_input_mungestat \
#    > ${PATH_OUT}/${PHENO}_betase_input_mungestat_clean

#interactively:
#/home/n/nnp5/software/ldsc/munge_sumstats.py \
#--sumstats ${PATH_OUT}/${PHENO}_betase_input_mungestat_clean \
#--N ${tot_n}   \
#--out ${PATH_OUT}/${PHENO}_allchr_step2_regenie \
#--merge-alleles /data/gen1/UKBiobank/Smoking/Meta_Analysis_AWI_UGR_UKBAFR/files/w_hm3.snplist \
#--chunksize 500000

#/home/n/nnp5/software/ldsc/ldsc.py \
#--h2 ${PATH_OUT}/${PHENO}_allchr_step2_regenie.sumstats.gz \
#--ref-ld-chr /data/gen1/reference/ldsc/afr_w_ld_chr/ \
#--w-ld-chr /data/gen1/reference/ldsc/afr_w_ld_chr/ \
#--out ${PATH_OUT}/${PHENO}_allchr_step2_regenie_h2

#conda deactivate
#cd /home/n/nnp5/PhD/PhD_project/REGENIE_assoc/

#Plots:
ldsc_intercept='1.03'

#run Manhattan, qqplot, lambda for all vars:
#PHENO="pheno_1_5_ratio"
#module unload R/4.2.1
#module load R/4.1.0
#chmod o+x src/REGENIE_plots.R
#dos2unix src/REGENIE_plots.R
#Rscript src/REGENIE_plots.R ${PATH_OUT}/${PHENO}_betase_input_mungestat ${PHENO} ${ldsc_intercept}

#run Manhattan, qqplot, lambda for vars with maf >= 0.01:
PHENO="maf001_pheno_1_5_ratio"
module unload R/4.2.1
module load R/4.1.0
chmod o+x src/REGENIE_plots.R
dos2unix src/REGENIE_plots.R
Rscript src/REGENIE_plots.R ${PATH_OUT}/${PHENO}_betase_input_mungestat ${PHENO} ${ldsc_intercept}

#Sentinel selection:
#PHENO="pheno_1_5_ratio"
#module unload R/4.2.1
#module load R/4.1.0
#chmod o+x src/sentinel_selection.R
#dos2unix src/sentinel_selection.R
#Rscript src/sentinel_selection.R ${PATH_OUT}/${PHENO}_betase_input_mungestat ${PHENO}

PHENO="maf001_pheno_1_5_ratio"
#module unload R/4.2.1
#module load R/4.1.0
#chmod o+x src/sentinel_selection.R
#dos2unix src/sentinel_selection.R
#Rscript src/sentinel_selection.R ${PATH_OUT}/${PHENO}_betase_input_mungestat ${PHENO}

#extract only genome-wide significant variants:
awk -F "\t" '$9 <= 0.00000005 {print $0}' ${PATH_OUT}/${PHENO}_betase_input_mungestat \
    > ${PATH_OUT}/${PHENO}_genomewide_signif