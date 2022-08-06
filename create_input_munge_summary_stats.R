#!/usr/bin/env Rscript

library(data.table)
library(tidyverse)

args = commandArgs(trailingOnly=TRUE)
df_file <- args[1]
pheno <- as.character(args[2])
cases_n <- as.numeric(args[3])
controls_n <- as.numeric(args[4])

df <- fread(df_file,header=TRUE)

#CHROM GENPOS ID ALLELE0 ALLELE1 A1FREQ INFO N TEST BETA SE CHISQ LOG10P EXTRA
#REGENIE: reference allele (allele 0), alternative allele (allele 1)

dfclean <- df %>% select(CHROM,ID,GENPOS,ALLELE1,ALLELE0,A1FREQ,LOG10P,BETA,SE)

dfclean$pval <- 10^(dfclean$LOG10P)

#k:cases_proportion:
dfclean$k <- cases_n/controls_n
dfclean$'LOG_ODDS' <- dfclean$BETA/(dfclean$k*(1-dfclean$k))
dfclean$'se_LOG_ODDS' <- dfclean$SE/(dfclean$k*(1-dfclean$k))

#select column in order:
dfclean <- dfclean %>% select(ID,CHROM,GENPOS,ALLELE1,ALLELE0,LOG_ODDS,se_LOG_ODDS,A1FREQ,LOG10P)

#rename columns :
colnames(dfclean) <- c("snpid", "b37chr", "bp", "a1", "a2", "LOG_ODDS", "se", "eaf", "pval")

write.table(dfclean,paste0("output/",pheno,"_input_mungestat"),quote=FALSE,sep="\t",row.names=FALSE)