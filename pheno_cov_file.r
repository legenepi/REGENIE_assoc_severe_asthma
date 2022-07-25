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
demo <- demo%>% filter(!is.na(pheno))
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

write.table(demo,paste0(output_prefix,"demo_pheno_cov.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ", na = "NA")

demo_EUR <- demo %>% filter(clustered.ethnicity == 'European')
write.table(demo_EUR,paste0(output_prefix,"demo_EUR_pheno_cov.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ", na = "NA")

#create sample file for bgen: NOT SURE
sample <- demo %>% select(FID, IID, genetic_sex)
colnames(sample) <- c("ID_1","ID_2","genetic_sex")
sample <- sample %>% mutate(sex = ifelse(sample$genetic_sex == 0, "2",
                                  ifelse(sample$genetic_sex == 1, "1"), "0")
sample$sex <- as.factor(sample$sex)
sample$missing <- as.factor("0")
sample <- sample %>% select(FID, IID,missing,sex)
first_line <- data.frame("0", "0", "0", "D")
colnames(first_line) <- c("ID_1", "ID_2", "missing", "sex")
sample <- rbind(first_line,sample)
write.table(sample,paste0(output_prefix,"demo_EUR_pheno_cov.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep=" ", na = "NA")



