#!/usr/bin/env Rscript

library(tidyverse)
library(data.table)
library(hudson)

args = commandArgs(trailingOnly=TRUE)

#Run it as:
#Rscript output/maf001_broad_pheno_1_5_ratio_betase_input_mungestat output/maf001_broad_pheno_female_betase_input_mungestat "broad_pheno" "broad_pheno_female"


sumstat1_file <- args[1]
sumstat2_file <- args[2]
pheno1 <- args[3]
pheno2 <- args[4]

sumstat1 <- fread(sumstat1_file,header=T,sep="\t") %>% select('snpid','b37chr','bp','pval')

sumstat2 <- fread(sumstat2_file,header=T,sep="\t") %>% select('snpid','b37chr','bp','pval')

colnames(sumstat1) <- c("SNP","CHR","BP","P")
colnames(sumstat2) <- c("SNP","CHR","BP","P")

sumstat1$P <- as.numeric(sumstat1$P)
sumstat2$P <- as.numeric(sumstat2$P)
sumstat1 <- sumstat1 %>% filter(P < 0.05 ) %>% rename(POS = BP,pvalue = P)
sumstat2 <- sumstat2 %>% filter(P < 0.05 ) %>% rename(POS = BP,pvalue = P)

top_title_name <- paste0(pheno1)
bottom_title_name <- paste0(pheno2)
file_name <- paste0('output/Miami_plot_Eur_UKBB','_',pheno1,'_VS_',pheno2)
gmirror(top=sumstat1, bottom=sumstat2, tline=5E-08, bline=5E-08, toptitle=top_title_name, bottomtitle=bottom_title_name, file=file_name)