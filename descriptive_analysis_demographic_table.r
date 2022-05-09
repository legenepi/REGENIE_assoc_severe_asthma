#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)
library(plotrix)


#function to find N valid values, mean and standard error for a quantitative variable in a dataset:
##NB: dataset needs to have quantitative variable only !
quant_descr <- function(dataset) {
for (col in colnames(dataset)){
print(paste0("column:",col))
print(paste0("N valid values:",length(na.omit(dataset[[col]]))))
print(paste0("mean:",mean(dataset[[col]],na.rm=TRUE)))
print(paste0("std error:",std.error(dataset[[col]],na.rm)))
print("-------------------------------")}}

#load input:
path_prefix <- "/home/n/nnp5/PhD/PhD_project/REGENIE_assoc/data/"

demo_file <- paste0(path_prefix,"demo_pheno_cov.txt")

demo <- fread(demo_file,fill=TRUE)

#make eid, genetic_sex, pheno_modsev_all_age categorical variables:
demo$eid <- as.factor(demo$eid)
demo$genetic_sex <- as.factor(demo$genetic_sex)
demo$pheno_modsev_all_age <- as.factor(demo$pheno_modsev_all_age)
#make age_onset_merge numeric:
demo$age_onset_merge <- as.numeric(demo$age_onset_merge)


#remove any participant neither case nor control for pheno_modsev_all_age
modsev_demo <- demo %>% filter(!is.na(pheno_modsev_all_age))

#case/control and male/female subdivision

#modsev descriptive:
modsev_demo_quantitative <- modsev_demo %>% select(eid, genetic_sex, pheno_modsev_all_age,
                                                            age_at_recruitment,
                                                            BMI,
                                                            age_onset_merge,
                                                            best_FEV1,
                                                            perc_pred_FEV1,
                                                            ratio_FEV1_FVC,
                                                            cigarette_pack_years
                                                            )
#all modsev dataset:
quant_descr(modsev_demo_quantitative[,-c(1,2,3)])

#case modsev dataset:
case_modsev_demo_quantitative <- modsev_demo_quantitative %>% filter(pheno_modsev_all_age == 1)
quant_descr(case_modsev_demo_quantitative[,-c(1,2,3)])
female_case_modsev_demo_quantitative <- case_modsev_demo_quantitative %>% filter(genetic_sex == "0")
quant_descr(female_case_modsev_demo_quantitative[,-c(1,2,3)])
male_case_modsev_demo_quantitative <- case_modsev_demo_quantitative %>% filter(genetic_sex == "1")
quant_descr(male_case_modsev_demo_quantitative[,-c(1,2,3)])

#control modsev dataset:
control_modsev_demo_quantitative <- modsev_demo_quantitative %>% filter(pheno_modsev_all_age == 0)
quant_descr(control_modsev_demo_quantitative[,-c(1,2,3)])
female_control_modsev_demo_quantitative <- control_modsev_demo_quantitative %>% filter(genetic_sex == "0")
quant_descr(female_control_modsev_demo_quantitative[,-c(1,2,3)])
male_control_modsev_demo_quantitative <- control_modsev_demo_quantitative %>% filter(genetic_sex == "1")
quant_descr(male_control_modsev_demo_quantitative[,-c(1,2,3)])
