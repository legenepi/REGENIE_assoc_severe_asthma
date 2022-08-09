#!/usr/bin/env Rscript

library(data.table)
library(tidyverse)

args = commandArgs(trailingOnly=TRUE)
df_file <- args[1]
pheno <- as.character(args[2])

df <- fread(df_file,header=TRUE)

#CHROM GENPOS ID ALLELE0 ALLELE1 A1FREQ INFO N TEST BETA SE CHISQ LOG10P EXTRA
#REGENIE: reference allele (allele 0), alternative allele (allele 1)

dfclean <- df %>% select(CHROM,ID,GENPOS,ALLELE1,ALLELE0,A1FREQ,LOG10P,BETA,SE)

dfclean$pval <- 10^(-dfclean$LOG10P)

#select column in order:
dfclean <- dfclean %>% select(ID,CHROM,GENPOS,ALLELE1,ALLELE0,BETA,SE,A1FREQ,pval)

#rename columns :
colnames(dfclean) <- c("snpid", "b37chr", "bp", "a1", "a2", "LOG_ODDS", "se", "eaf", "pval")

write.table(dfclean,paste0("output/",pheno,"_betase_input_mungestat"),quote=FALSE,sep="\t",row.names=FALSE)