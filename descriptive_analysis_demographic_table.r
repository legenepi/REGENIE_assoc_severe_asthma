#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)
library(plotrix)

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

#quantitative traits:
modsev_demo_quantitative <- modsev_demo %>% select(eid, genetic_sex, pheno_modsev_all_age,
                                                            age_at_recruitment,
                                                            BMI,
                                                            age_onset_merge,
                                                            best_FEV1,
                                                            perc_pred_FEV1,
                                                            ratio_FEV1_FVC,
                                                            cigarette_pack_years
                                                            )

for (col in colnames(modsev_demo_quantitative)[-c(1,2,3)]){
print(paste0("column:",col))
print(paste0("N valid values:",length(na.omit(modsev_demo_quantitative[[col]]))))
print(paste0("mean:",mean(modsev_demo_quantitative[[col]],na.rm=TRUE)))
print(paste0("std error:",std.error(modsev_demo_quantitative[[col]],na.rm)))
print("-------------------------------")
}
