#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)

noallergy_pheno_file <- "/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/eid_noallergy_EUR_pheno_broadasthma"

broad_eur_pheno_cov_file <- "/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/demo_EUR_pheno_cov_broadasthma.txt"


noallergy_pheno <- fread(noallergy_pheno_file, header=F)
colnames(noallergy_pheno) <- c("FID","noallergy_pheno")


broad_eur_pheno_cov <- fread(broad_eur_pheno_cov_file, header=T)

noallergy_pheno$FID <- as.factor(noallergy_pheno$FID)
broad_eur_pheno_cov$FID <- as.factor(broad_eur_pheno_cov$FID)

broad_eur_pheno_cov_noallergy <- left_join(broad_eur_pheno_cov,noallergy_pheno,by="FID")
broad_eur_pheno_cov_noallergy$noallergy_pheno <- as.factor(broad_eur_pheno_cov_noallergy$noallergy_pheno)

summary(as.factor(broad_eur_pheno_cov_noallergy$noallergy_pheno)) # ok, these are the number we want

output_prefix = "/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/"
write.table(broad_eur_pheno_cov_noallergy,paste0(output_prefix,"demo_EUR_pheno_cov_broadasthma_noallergy.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ", na = "NA")
