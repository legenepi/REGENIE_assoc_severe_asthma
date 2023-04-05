#!/bin/bash

#PBS -N check_regenie_broad_pheno
#PBS -j oe
#PBS -o log_check_regenie_broad_pheno
#PBS -l walltime=1:0:0
#PBS -l vmem=50gb
#PBS -l nodes=1:ppn=1
#PBS -d .
#PBS -W umask=022


#Set variables:
PATH_OUT="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output"
PHENO="broad_pheno_1_5_ratio"

#mkdir ${PATH_OUT}/allchr
GWAS="/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/output/allchr"


#merge all assoc file:
#zcat ${PATH_OUT}/${PHENO}.1.regenie.step2_${PHENO}.regenie.gz | tail -n +2 | \
#     awk -F " " '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13}' \
#    > ${GWAS}/check_${PHENO}_allchr.assoc.txt

#for i in {2..22}
#    do zcat ${PATH_OUT}/${PHENO}.${i}.regenie.step2_${PHENO}.regenie.gz | \
#    tail -n +2 | awk -F " " '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13}' \
#    >> ${GWAS}/check_${PHENO}_allchr.assoc.txt
#done

#gzip ${GWAS}/check_${PHENO}_allchr.assoc.txt

#check the check sumstat with the original sumstat:
#for i in {1..22}; do echo $i; zcat ${PATH_OUT}/${PHENO}.${i}.regenie.step2_${PHENO}.regenie.gz | \
#    wc -l; done > ${PATH_OUT}/check_regenie_broad_pheno

#for i in {1..22}; do echo $i; zcat ${GWAS}/broad_pheno_1_5_ratio_allchr.assoc.txt.gz | \
#    awk -v chr=$i '$1 == chr {print}' | wc -l; done >> ${PATH_OUT}/check_regenie_broad_pheno

#then in R interactively:
#module unload R/4.2.1
#module load R/4.1.0
#library(tidyverse)
#library(data.table)
#df <- fread("output/allchr/broad_pheno_1_5_ratio_allchr.assoc.txt.gz",header=F)
#df2 <- fread("output/allchr/check_broad_pheno_1_5_ratio_allchr.assoc.txt.gz",header=F)
#df <- df %>% mutate_at(vars(V6, V7, V10, V11, V12, V13), funs(round(., 3)))
#df2 <- df2 %>% mutate_at(vars(V6, V7, V10, V11, V12, V13), funs(as.numeric(.)))
#df2 <- df2 %>% mutate_at(vars(V6, V7, V10, V11, V12, V13), funs(round(., 3)))
#df3 <- inner_join(df,df2)
#Some variants are lot due to slightly different rounding. I conclude that the result are pretty much the same.



