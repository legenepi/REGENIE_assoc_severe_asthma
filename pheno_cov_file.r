#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)

#load input:
path_prefix <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"
output_prefix <- "/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/data/"

demo_file <- paste0(path_prefix,"demographics.txt")

demo <- fread(demo_file,sep="\t")

demo$pheno_all_age <- "NA"

demo <- demo %>% mutate(pheno_all_age = ifelse(demo$modsev_asthma == 1, 1,
ifelse(demo$controls == 1, 0, "NA")))

demo <- demo %>% mutate(pheno_all_age = case_when(modsev_asthma == 1 ~ 1
                                                 ,controls == 1 ~ 1
                                                 , TRUE ~ 'NA')

demo <- demo %>%
  mutate(pheno_modsev_all_age = case_when(modsev_asthma == 1 ~ 1
                                ,controls == 1 ~ 0
                                ,TRUE ~ as.numeric(pheno_all_age)
                                )
  )

demo <- demo %>%
  mutate(pheno_modsev_adult = ifelse(demo$pheno_modsev_all_age == 1 & demo$category_onset == 'adult_onset', 1,
  ifelse(demo$pheno_modsev_all_age == 0, 0, as.numeric(demo$pheno_modsev_adult))))


demo <- demo %>%
  mutate(pheno_modsev_early = ifelse(demo$pheno_modsev_all_age == 1 & demo$category_onset == 'early_onset', 1,
  ifelse(demo$pheno_modsev_all_age == 0, 0, as.numeric(demo$pheno_modsev_early))))

demo %>% filter(pheno_modsev_all_age == 1) %>% count(clustered.ethnicity)
demo %>% filter(pheno_modsev_adult == 1) %>% count(clustered.ethnicity)
demo %>% filter(pheno_modsev_early == 1) %>% count(clustered.ethnicity)

demo_EUR <- demo %>% filter(clustered.ethnicity == 'European')

#assemble the phenotypes-covariates file
demo_EUR$FID <- demo_EUR$eid
demo_EUR$IID <- demo_EUR$eid

demo_EUR$age2 <- demo_EUR$age_at_recruitment * demo_EUR$age_at_recruitment

demo_EUR_pheno_cov <- demo_EUR %>% select(FID,
                                          IID,
                                          everything())

write.table(demo_EUR_pheno_cov,paste0(output_prefix,"demo_EUR_pheno_cov.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ")

