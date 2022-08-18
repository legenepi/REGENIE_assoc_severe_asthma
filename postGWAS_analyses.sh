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
#zcat ${PATH_OUT}/${PHENO}.1.regenie.step2_pheno_1_5_ratio.regenie.gz | tail -n +2 | \
#     awk -F " " '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13}' \
#    > ${GWAS}/${PHENO}_allchr.assoc.txt

#for i in {2..22}
#    do zcat ${PATH_OUT}/${PHENO}.${i}.regenie.step2_pheno_1_5_ratio.regenie.gz | \
#    tail -n +2 | awk -F " " '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13}' \
#    >> ${GWAS}/${PHENO}_allchr.assoc.txt
#done


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

tot_n=27408
PHENO="maf001_pheno_1_5_ratio"

#awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9}' ${PATH_OUT}/${PHENO}_betase_input_mungestat \
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
#--ref-ld-chr /data/gen1/reference/ldsc/eur_w_ld_chr/ \
#--w-ld-chr /data/gen1/reference/ldsc/eur_w_ld_chr/ \
#--out ${PATH_OUT}/${PHENO}_allchr_step2_regenie_h2

#conda deactivate
#cd /home/n/nnp5/PhD/PhD_project/REGENIE_assoc/

#Plots:
ldsc_intercept='1.03'


#run Manhattan, qqplot, lambda for vars with maf >= 0.01:
module unload R/4.2.1
module load R/4.1.0
chmod o+x src/REGENIE_plots.R
dos2unix src/REGENIE_plots.R
Rscript src/REGENIE_plots.R ${PATH_OUT}/${PHENO}_betase_input_mungestat ${PHENO} ${ldsc_intercept}

#Sentinel selection:
PHENO="maf001_pheno_1_5_ratio"
module unload R/4.2.1
module load R/4.1.0
chmod o+x src/sentinel_selection.R
dos2unix src/sentinel_selection.R
Rscript src/sentinel_selection.R ${PATH_OUT}/${PHENO}_betase_input_mungestat ${PHENO}

#extract only genome-wide significant variants:
awk -F "\t" '$9 <= 0.00000005 {print $0}' ${PATH_OUT}/${PHENO}_betase_input_mungestat \
    > ${PATH_OUT}/${PHENO}_genomewide_signif


#find the imputation info score for sentinel variants:
#awk '{print $1}' ${PATH_OUT}/${PHENO}_sentinel_variants.txt | \
#    zgrep -w -F -f - \
#    /data/gen1/UKBiobank/Smoking/all_ancestries_500K/nonEU_smk_beh_assoc/ukbafr_noemi/imputed_no_withdrawn/snp.stats.chr*.txt.gz

#find association pvalue in moderate-to-severe sumstat:
#rsid chromosome position alleleA alleleB MAF INFO beta se_gc P_gc
#touch ${PATH_OUT}/${PHENO}_sentinelvars_in_moderatesev_sumstat.txt

#awk '{print $1}' ${PATH_OUT}/${PHENO}_sentinel_variants.txt | \
#    zgrep -w -F -f - /data/gen1/AIRPROM/assoc/severe_asthma_GC.snptest.gz | \
#    awk '{print $1, $2, $3, $4, $5, $7, $9, $10, $13, $14}' \
#    >> ${PATH_OUT}/${PHENO}_sentinelvars_in_moderatesev_sumstat.txt

#zcat /data/gen1/AIRPROM/assoc/severe_asthma_GC.snptest.gz | awk '{print $1, $2, $3, $4, $5, $7, $9, $10, $13, $14}' | \
#    grep "5 131770805\|8 81266924\|10 9042744" \
#    >> ${PATH_OUT}/${PHENO}_sentinelvars_in_moderatesev_sumstat.txt

#zgrep -w "rs560026225\|rs72687036\|rs10905284\|rs10905284\|rs11603634\|rs11603634" \
#    ${PATH_OUT}/allchr/pheno_1_5_ratio_allchr.assoc.txt.gz > ${PATH_OUT}/novelmodsev_in_difficulttotreat.txt