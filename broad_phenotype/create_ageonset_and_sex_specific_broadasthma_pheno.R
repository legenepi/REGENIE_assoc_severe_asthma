#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)

broad_pheno_file <- "/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/demo_EUR_pheno_cov_broadasthma.txt"

broad_pheno <- fread(broad_pheno_file, header=T)

#Adult-onset
broad_pheno$broad_pheno_adultonset <- broad_pheno$broad_pheno_1_5_ratio
broad_pheno <- broad_pheno %>% mutate(broad_pheno_adultonset = ifelse(broad_pheno$category_onset == 'onset_early' & broad_pheno$broad_pheno_1_5_ratio == 1, "NA", broad_pheno$broad_pheno_adultonset))


#Childhood-onset:
broad_pheno$broad_pheno_childhoodonset <- broad_pheno$broad_pheno_1_5_ratio
broad_pheno <- broad_pheno %>% mutate(broad_pheno_childhoodonset = ifelse(broad_pheno$category_onset == 'onset_adult' & broad_pheno$broad_pheno_1_5_ratio == 1, "NA", broad_pheno$broad_pheno_childhoodonset))


#Female:
broad_pheno$broad_pheno_female <- broad_pheno$broad_pheno_1_5_ratio
broad_pheno <- broad_pheno %>% mutate(broad_pheno_female = ifelse(broad_pheno$genetic_sex == 1 & broad_pheno$broad_pheno_1_5_ratio == 1, "NA",
ifelse(broad_pheno$genetic_sex == 1 & broad_pheno$broad_pheno_1_5_ratio == 0, "NA", broad_pheno$broad_pheno_female)))

#Male:
broad_pheno$broad_pheno_male <- broad_pheno$broad_pheno_1_5_ratio
broad_pheno <- broad_pheno %>% mutate(broad_pheno_male = ifelse(broad_pheno$genetic_sex == 0 & broad_pheno$broad_pheno_1_5_ratio == 1, "NA",
ifelse(broad_pheno$genetic_sex == 0 & broad_pheno$broad_pheno_1_5_ratio == 0, "NA", broad_pheno$broad_pheno_male)))

output_prefix = "/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/"
write.table(broad_pheno,paste0(output_prefix,"demo_EUR_pheno_cov_broadasthma_ageonset_sexstratified.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ", na = "NA")