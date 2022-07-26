#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)

#load input:
path_prefix_1 <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"
path_prefix_2 <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_asthmaMeds_stratification/data/"
output_prefix <- "/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/data/"

demo_file <- paste0(path_prefix_1,"demographics.txt")

demo <- fread(demo_file,sep="\t")

severe <- fread(paste0(path_prefix_2,"Eid_severe_intersection"),header=F)
colnames(severe)[1] <- "eid"
severe$cases <- as.factor("1")

demo <- left_join(demo,severe,by="eid")


demo <- demo %>% mutate(pheno = case_when(controls == 1 ~ 0, cases == 1 ~ 1))
demo$pheno <- as.factor(demo$pheno)

demo <- demo %>%
  mutate(pheno_adult = ifelse(demo$pheno == 1 & demo$category_onset == 'onset_adult', 1, as.numeric(demo$pheno_adult)))


demo <- demo %>%
  mutate(pheno_early = ifelse(demo$pheno == 1 & demo$category_onset == 'onset_early', 1, as.numeric(demo$pheno_modsev_early)))

demo %>% filter(pheno == 1) %>% count(clustered.ethnicity)
demo %>% filter(pheno_adult == 1) %>% count(clustered.ethnicity)
demo %>% filter(pheno_early == 1) %>% count(clustered.ethnicity)



#assemble the phenotypes-covariates file
demo$FID <- demo$eid
demo$IID <- demo$eid

demo <- demo %>% select(FID,
                        IID,
                        everything())

demo$age2 <- demo$age_at_recruitment * demo$age_at_recruitment



#order as the sample file:
sample <- fread("/data/gen1/UKBiobank_500K/severe_asthma/data/ukbiobank_app56607_for_regenie.sample",header=T)
sample <- sample[-1,]
colnames(sample) <- c("FID","IID","missing","genetic_sex")
sample_FID_IID <- sample %>% select(FID, IID)

sample$genetic_sex <- as.factor(sample$genetic_sex)
demo$genetic_sex <- as.factor(demo$genetic_sex)

sample_demo <- left_join(sample,demo,by=c("FID","IID"))

write.table(sample_demo,paste0(output_prefix,"demo_pheno_cov.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ", na = "NA")

sample_demo_EUR <- sample_demo %>% filter(clustered.ethnicity == 'European')
write.table(sample_demo_EUR,paste0(output_prefix,"demo_EUR_pheno_cov.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ", na = "NA")
