#!/usr/bin/env Rscript

#run this file as:
#source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate
#module unload R/4.2.1
#module load R/4.1.0

#upload required libraries
library(data.table)
library(tidyverse)

#load input:
path_prefix_1 <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"
output_prefix <- "/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/data/"

demo_file <- paste0(path_prefix_1,"demographics.txt")

demo <- fread(demo_file,sep="\t")

#create pheno cols:
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
colnames(sample) <- c("FID","IID","missing","sex_sample_file")
sample_FID_IID <- sample %>% select(FID, IID)

sample$sex_sample_file <- as.factor(sample$sex_sample_file)
demo$genetic_sex <- as.factor(demo$genetic_sex)

sample_demo <- left_join(sample,demo,by=c("FID","IID"))

write.table(sample_demo,paste0(output_prefix,"demo_pheno_cov.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ", na = "NA")

sample_demo_EUR <- sample_demo %>% filter(clustered.ethnicity == 'European')
cases_sample_demo_EUR <- sample_demo_EUR %>% filter(pheno == 1)

female_cases_count <- as.numeric(summary(as.factor(cases_sample_demo_EUR$genetic_sex))[1])*5
male_cases_count <- as.numeric(summary(as.factor(cases_sample_demo_EUR$genetic_sex))[2])*5

controls_sample_demo_EUR <- sample_demo_EUR %>% filter(pheno == 0)

female_controls_sample_demo_EUR <- controls_sample_demo_EUR %>% filter(genetic_sex == 0)
female_controls_sample_demo_EUR <- female_controls_sample_demo_EUR[1:female_cases_count,1]

male_controls_sample_demo_EUR <- controls_sample_demo_EUR %>% filter(genetic_sex == 1)
male_controls_sample_demo_EUR <- male_controls_sample_demo_EUR[1:male_cases_count,1]
controls_eid <- rbind(male_controls_sample_demo_EUR,female_controls_sample_demo_EUR)

#pheno in EUR with case:control ratio 1:5 and primary prescription:
sample_demo_EUR <- sample_demo_EUR %>% mutate(pheno_1_5_ratio = ifelse(sample_demo_EUR$FID %in% controls_eid$FID, 0,
                                                                ifelse(sample_demo_EUR$cases == 1, 1, "NA")))

summary(as.factor(sample_demo_EUR$pheno_1_5_ratio)) # ok, these are the number we want

write.table(sample_demo_EUR,paste0(output_prefix,"demo_EUR_pheno_cov.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ", na = "NA")

