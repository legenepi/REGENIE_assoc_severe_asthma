#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)

#load input:
path_prefix <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"
output_prefix <- "/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/data/"

demo_file <- paste0(path_prefix,"demographics.txt")

demo <- fread(demo_file,sep="\t")

demo <- demo %>%
  mutate(pheno_allasthma_all_age = case_when(asthma_diagnosis == 1 ~ 1,
                                controls == 1                ~ 0,
                                TRUE                         ~ as.numeric('NA')))

demo <- demo %>%
  mutate(pheno_modsev_all_age = case_when(modsev_asthma == 1 ~ 1,
                                controls == 1                ~ 0,
                                TRUE                         ~ as.numeric('NA')))


demo <- demo %>%
  mutate(pheno_modsev_adult = ifelse(demo$pheno_modsev_all_age == 1 & demo$category_onset == 'onset_adult', 1,
  ifelse(demo$pheno_modsev_all_age == 0, 0, as.numeric(demo$pheno_modsev_adult))))


demo <- demo %>%
  mutate(pheno_modsev_early = ifelse(demo$pheno_modsev_all_age == 1 & demo$category_onset == 'onset_early', 1,
  ifelse(demo$pheno_modsev_all_age == 0, 0, as.numeric(demo$pheno_modsev_early))))

demo %>% filter(pheno_modsev_all_age == 1) %>% count(clustered.ethnicity)
demo %>% filter(pheno_modsev_adult == 1) %>% count(clustered.ethnicity)
demo %>% filter(pheno_modsev_early == 1) %>% count(clustered.ethnicity)



#assemble the phenotypes-covariates file
demo$FID <- demo$eid
demo$IID <- demo$eid

demo <- demo %>% select(FID,
                        IID,
                        everything())

demo$age2 <- demo$age_at_recruitment * demo$age_at_recruitment

write.table(demo,paste0(output_prefix,"demo_pheno_cov.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ", na = "NA")

demo_EUR <- demo %>% filter(clustered.ethnicity == 'European')
write.table(demo_EUR,paste0(output_prefix,"demo_EUR_pheno_cov.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ", na = "NA")

