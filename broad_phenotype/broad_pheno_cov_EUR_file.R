#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)

broad_pheno_file <- "/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/eid_broad_asthma_pheno"

eur_pheno_cov_file <- "/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/demo_EUR_pheno_cov.txt"

broad_pheno <- fread(broad_pheno_file, header=F)
colnames(broad_pheno) <- "FID"
broad_pheno$cases_broad <- as.factor(1)

eur_pheno_cov <- fread(eur_pheno_cov_file, header=T)

eur_pheno_cov_broad_pheno <- left_join(eur_pheno_cov,broad_pheno,by="FID")
eur_pheno_cov_broad_pheno_eur_cases <- eur_pheno_cov_broad_pheno %>% filter(clustered.ethnicity == "European" & cases_broad == 1) %>% select(FID,cases_broad)
eur_pheno_cov_broad_pheno_eur_cases$cases_broad_EUR <- as.factor(1)

sample_demo <- left_join(eur_pheno_cov,eur_pheno_cov_broad_pheno_eur_cases,by="FID")

sample_demo_EUR <- sample_demo %>% filter(clustered.ethnicity == 'European')
cases_sample_demo_EUR <- sample_demo_EUR %>% filter(cases_broad_EUR == 1)

female_cases_count <- as.numeric(summary(as.factor(cases_sample_demo_EUR$genetic_sex))[1])*5
male_cases_count <- as.numeric(summary(as.factor(cases_sample_demo_EUR$genetic_sex))[2])*5

controls_sample_demo_EUR <- sample_demo_EUR %>% filter(controls == 1)

female_controls_sample_demo_EUR <- controls_sample_demo_EUR %>% filter(genetic_sex == 0)
female_controls_sample_demo_EUR <- female_controls_sample_demo_EUR[1:female_cases_count,1]

male_controls_sample_demo_EUR <- controls_sample_demo_EUR %>% filter(genetic_sex == 1)
male_controls_sample_demo_EUR <- male_controls_sample_demo_EUR[1:male_cases_count,1]
controls_eid <- rbind(male_controls_sample_demo_EUR,female_controls_sample_demo_EUR)

#broad pheno in EUR with case:control ratio 1:5 and primary prescription:
sample_demo_EUR <- sample_demo_EUR %>% mutate(broad_pheno_1_5_ratio = ifelse(sample_demo_EUR$FID %in% controls_eid$FID, 0,
                                                                ifelse(sample_demo_EUR$cases_broad_EUR == 1, 1, "NA")))

summary(as.factor(sample_demo_EUR$broad_pheno_1_5_ratio)) # ok, these are the number we want

output_prefix = "/data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/"
write.table(sample_demo_EUR,paste0(output_prefix,"demo_EUR_pheno_cov_broadasthma.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ", na = "NA")





